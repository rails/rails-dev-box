Facter.add("apt_package_updates") do
  confine :osfamily => 'Debian'
  setcode do
    if File.executable?("/usr/lib/update-notifier/apt-check")
      packages = Facter::Util::Resolution.exec('/usr/lib/update-notifier/apt-check -p 2>&1')
      packages = packages.split("\n")
      if Facter.version < '2.0.0'
        packages = packages.join(',')
      end
      packages
    end
  end
end
