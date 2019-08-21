# frozen_string_literal: true

module Helsinki
  module BudgetingVerification
    class AuthorizationsController < Decidim::ApplicationController
      # The UserProfile concern provides the `available_verification_workflows`
      # method.
      include Decidim::UserProfile

      layout "layouts/decidim/application"

      helper_method :authorization, :verifications, :handler

      before_action :load_authorization
      skip_before_action :store_current_location

      def new
        enforce_permission_to :create, :authorization, authorization: @authorization

        return render :identify unless is_user_identified?
        unless eligible_for_voting?
          @errors = conditions_checker.error_messages
          return render :error
        end

        handler.district = find_area_from_metadata
      end

      def create
        enforce_permission_to :create, :authorization, authorization: @authorization
        return redirect_to new_authorization_path unless eligible_for_voting?

        auth = perform_authorization
        return redirect_to(decidim_verifications.authorizations_path) unless auth

        if params[:redirect_url]
          redirect_to params[:redirect_url]
        else
          redirect_to(
            stored_location_for(:user) ||
            decidim_verifications.authorizations_path
          )
        end
      end

      def destroy
        enforce_permission_to :create, :authorization, authorization: @authorization

        # TODO
      end

      private

      def handler
        @handler ||= RequestForm.from_params(handler_params.merge(
          handler_handle: authorization_handle
        ))
      end

      def handler_params
        (params[:budgeting_verification] || {}).merge(user: current_user)
      end

      def strong_authorization
        @strong_authorization ||= begin
          if granted_authorization_handles.include?(:helsinki_documents_authorization_handler)
            granted_authorization(:helsinki_documents_authorization_handler)
          elsif granted_authorization_handles.include?(:suomifi_eid)
            granted_authorization(:suomifi_eid)
          elsif granted_authorization_handles.include?(:mpassid_nids)
            granted_authorization(:mpassid_nids)
          end
        end
      end

      def perform_authorization
        return nil unless strong_authorization

        uid = Digest::MD5.hexdigest(
          "#{strong_authorization.unique_id}-#{Rails.application.secrets.secret_key_base}"
        )
        existing = Decidim::Authorization.find_by(
          unique_id: uid,
          organization: current_organization
        )

        auth = authorization
        if existing
          return nil if existing.user != current_user
          auth = existing
        end

        auth.attributes = {
          unique_id: uid,
          metadata: {district: handler.district}
        }
        auth.save!
        auth.grant!
        auth
      end

      def find_area_from_metadata
        case strong_authorization.name.to_sym
        when :helsinki_documents_authorization_handler
          find_area_by_postal_code
        when :suomifi_eid
          find_area_by_postal_code
        when :mpassid_nids
          find_area_from_mpassid
        end
      end

      def find_area_by_postal_code
        Helsinki::DistrictMetadata.postal_code_for_subdivision(
          strong_authorization.metadata["postal_code"]
        )
      end

      def find_area_from_mpassid
        postal_code = Helsinki::SchoolMetadata.postal_code_for_school(
          strong_authorization.metadata["school_code"]
        )
        return nil unless postal_code

        Helsinki::DistrictMetadata.postal_code_for_subdivision(
          postal_code
        )
      end

      def is_user_identified?
        verification_handles.each do |handle|
          return true if granted_authorization_handles.include?(handle)
        end

        false
      end

      def conditions_checker
        @conditions_checker ||= begin
          case strong_authorization.name.to_sym
          when :helsinki_documents_authorization_handler
            MunicipalityAgeConditions.new(strong_authorization)
          when :suomifi_eid
            MunicipalityAgeConditions.new(strong_authorization)
          when :mpassid_nids
            MpassConditions.new(strong_authorization)
          end
        end
      end

      def eligible_for_voting?
        conditions_checker.valid?
      end

      def verification_handles
        @verification_handles ||= begin
          [
            :helsinki_documents_authorization_handler,
            :suomifi_eid,
            :mpassid_nids
          ]
        end
      end

      def verifications
        @verifications ||= available_verification_workflows.select do |handler|
          verification_handles.include?(handler.key.to_sym)
        end
      end

      def granted_authorization_handles
        @granted_authorization_handles ||= Decidim::Verifications::Authorizations.new(
          organization: current_organization,
          user: current_user,
          granted: true
        ).pluck(:name).map(&:to_sym)
      end

      def granted_authorization(name)
        Decidim::Authorization.where.not(granted_at: nil).find_by(
          user: current_user,
          name: name
        )
      end

      # rubocop:disable Naming/MemoizedInstanceVariableName
      def authorization
        @authorization_presenter ||= AuthorizationPresenter.new(@authorization)
      end
      # rubocop:enable Naming/MemoizedInstanceVariableName

      def load_authorization
        @authorization = Decidim::Authorization.find_or_initialize_by(
          user: current_user,
          name: authorization_handle
        )
      end

      def authorization_handle
        # In case the form is posted, the authorization handle is not
        # available from the request path.
        tmpform = RequestForm.from_params(params)
        return tmpform.handler_name unless tmpform.handler_name.nil?

        # Determine the handle from the request path
        request.path.split("/").last
      end
    end
  end
end
