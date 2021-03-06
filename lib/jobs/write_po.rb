require 'fileutils'

class WritePo < Struct.new(:language, :translations)
  def perform
    file_name = "#{Rails.root}/po/#{language}/#{Rails.application.class.to_s.split('::').first.downcase}.po"

    lock_file(file_name) do
      File.atomic_write(file_name) { |f| f.print(translations) }
    end
  end

  private
    # Lock a file for a block so only one process can modify it at a time.
    def lock_file(file_name, &block) # :nodoc:
      if File.exist?(file_name)
        File.open(file_name, 'r+') do |f|
          begin
            f.flock File::LOCK_EX
            yield
          ensure
            f.flock File::LOCK_UN
          end
        end
      else
        yield
      end
    end
end