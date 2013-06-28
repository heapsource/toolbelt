require "zip/zip"

file pkg("nuvado-#{version}.zip") => distribution_files("zip") do |t|
  tempdir do |dir|
    mkchdir("nuvado-client") do
      assemble_distribution
      assemble_gems
      Zip::ZipFile.open(t.name, Zip::ZipFile::CREATE) do |zip|
        Dir["**/*"].each do |file|
          zip.add(file, file) { true }
        end
      end
    end
  end
end

file pkg("nuvado-#{version}.zip.sha256") => pkg("nuvado-#{version}.zip") do |t|
  File.open(t.name, "w") do |file|
    file.puts Digest::SHA256.file(t.prerequisites.first).hexdigest
  end
end

task "zip:build" => pkg("nuvado-#{version}.zip")
task "zip:sign"  => pkg("nuvado-#{version}.zip.sha256")

def zip_signature
  File.read(pkg("nuvado-#{version}.zip.sha256")).chomp
end

task "zip:clean" do
  clean pkg("nuvado-#{version}.zip")
end

task "zip:release" => %w( zip:build zip:sign ) do |t|
  store pkg("nuvado-#{version}.zip"), "nuvado-client/nuvado-client-#{version}.zip"
  store pkg("nuvado-#{version}.zip"), "nuvado-client/nuvado-client-beta.zip" if beta?
  store pkg("nuvado-#{version}.zip"), "nuvado-client/nuvado-client.zip" unless beta?
end
