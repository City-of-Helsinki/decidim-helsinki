# frozen_string_literal: true

require "rails_helper"

# Tests different cases for the aggration decumulation.
describe Helsinki::Stats::Voting::Aggregator do
  let(:aggregator) { described_class.new }

  let(:organization) { create(:organization) }
  let(:component) { create(:budgets_component, :with_minimum_budget_projects, vote_minimum_budget_projects_number: 1, organization: organization) }
  let(:budget) { create(:budget, component: component, total_budget: 100_000) }
  let!(:projects) do
    [
      create(:project, budget: budget, budget_amount: 5_000),
      create(:project, budget: budget, budget_amount: 10_000),
      create(:project, budget: budget, budget_amount: 20_000),
      create(:project, budget: budget, budget_amount: 30_000),
      create(:project, budget: budget, budget_amount: 40_000),
      create(:project, budget: budget, budget_amount: 50_000)
    ]
  end

  let!(:user1) { create(:user, :confirmed, locale: "en", name: "Aaroni Barbecuetes", organization: organization) }
  let!(:user1_authorization) do
    create(
      :authorization,
      user: user1,
      name: "suomifi_eid",
      unique_id: "suomifi_1",
      metadata: {
        date_of_birth: "1990-06-02",
        municipality: "091",
        postal_code: "00220",
        gender: nil
      }
    )
  end
  let!(:user2) { create(:user, :confirmed, locale: "en", name: "Aaroni Barbecuetes", organization: organization) }
  let!(:user2_authorization) do
    create(
      :authorization,
      user: user2,
      name: "suomifi_eid",
      unique_id: "suomifi_2",
      metadata: {
        date_of_birth: "1995-03-31",
        municipality: "091",
        postal_code: "00210",
        gender: nil
      }
    )
  end

  describe "aggregation" do
    # Aggregation runs once every hour at XX:05
    #
    # Runs at:
    # 2026-03-26T19:05:00
    # 2026-03-26T20:05:00
    # 2026-03-26T21:05:00
    #
    # cancelled_vote1
    # - cast_at: 2026-03-12T20:04:45+0000
    # - created_at: 2026-03-26T19:57:01+0000
    # - order
    #   - budget: 29
    #   - checked_out_at: 2026-03-12T20:04:45+0000
    #   - line_items: 2668
    #
    # cancelled_vote2
    # - cast_at: 2026-03-28T14:14:29+0000
    # - created_at: 2026-03-28T14:31:57+0000
    # - order
    #   - budget: 31
    #   - checked_out_at: 2026-03-28T14:14:29+0000
    #   - line_items: 2528, 3057
    #
    # cancelled_vote3
    # - cast_at: 2026-03-24T12:31:34+0000
    # - created_at: 2026-03-29T18:30:39+0000
    # - order
    #   - budget: 29
    #   - checked_out_at: 2026-03-24T12:31:34+0000
    #   - line_items: 2712
    context "when vote is cancelled normally" do
      before do
        vote_time = Time.zone.parse("2026-03-12T20:04:45+0000")
        vote = Decidim::Budgets::Vote.new(
          component: component,
          user: user1,
          created_at: vote_time
        )
        order = create(:order, created_at: vote_time, budget: budget, user: user1, vote: vote)
        order.projects << projects[0..2]
        order.update!(created_at: vote_time, checked_out_at: vote_time)

        # Run the aggregator
        aggregator.run
      end

      it "decumulates the vote correctly" do
        # First check that the initial aggrecation has run correctly.
        [component, budget, *projects[0..2]].each do |measurable|
          collection = measurable.stats.find_by(key: "votes")
          total = collection.sets.find_by(key: "total")
          expect(total.measurements.find_by(label: "all").value).to eq(1)
        end

        # Cancel and re-aggregate 2 times
        Decidim::Budgets::CancelledVote.cancel_vote!(Decidim::Budgets::Vote.first)
        aggregator.run
        aggregator.run

        # Check that the values were decumulated correctly
        [component, budget, *projects[0..2]].each do |measurable|
          collection = measurable.stats.find_by(key: "votes")
          total = collection.sets.find_by(key: "total")
          expect(total.measurements.find_by(label: "all").value).to eq(0)
        end
      end
    end

    context "when the vote is cast and cancelled in-between of aggregations" do
      before do
        vote_time = Time.zone.parse("2026-03-12T20:04:45+0000")
        vote = Decidim::Budgets::Vote.new(
          component: component,
          user: user1,
          created_at: vote_time
        )
        order = create(:order, budget: budget, user: user1, vote: vote)
        order.projects << projects[0..2]
        order.update!(created_at: vote_time, checked_out_at: vote_time)

        # Run the aggregator
        aggregator.run
      end

      it "decumulates the vote correctly" do
        # The vote that was cast and cancelled in-between the aggregator runs
        # should be omitted from the result.
        vote_time = Time.zone.parse("2026-03-28T14:14:29+0000")
        vote = Decidim::Budgets::Vote.new(
          component: component,
          user: user2,
          created_at: vote_time
        )
        order = create(:order, budget: budget, user: user2, vote: vote)
        order.projects << projects[3..4]
        order.update!(created_at: vote_time, checked_out_at: vote_time)

        # Cancel the new vote and re-aggregate 2 times
        Decidim::Budgets::CancelledVote.cancel_vote!(vote)
        aggregator.run
        aggregator.run

        [component, budget, *projects[0..2]].each do |measurable|
          collection = measurable.stats.find_by(key: "votes")
          total = collection.sets.find_by(key: "total")
          expect(total.measurements.find_by(label: "all").value).to eq(1)
        end

        projects[3..4].each do |measurable|
          collection = measurable.stats.find_by(key: "votes")
          total = collection.sets.find_by(key: "total")
          expect(total).to be_nil
        end
      end
    end
  end
end
