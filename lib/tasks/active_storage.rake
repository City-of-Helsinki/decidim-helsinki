# frozen_string_literal: true

namespace :active_storage do
  desc "Mirrors all active storage files"
  task mirror_all: [:environment] do
    mirror_service = ActiveStorage::Blob.services.fetch(:mirror)

    ActiveStorage::Blob.all.each do |blob|
      puts "Mirroring #{blob.key}"
      mirror_service.mirror(blob.key, checksum: blob.checksum)
    end
    puts "Done"
  end

  desc "Change blob service name to the service define through the arguments"
  task :switch_to, [:service_name] => [:environment] do |_t, args|
    ActiveStorage::Blob.update_all(service_name: args[:service_name]) # rubocop:disable Rails/SkipsModelValidations
  end
end
