Facter.add("apt_updates") do
  confine :osfamily => 'Debian'
  setcode do
    if File.executable?("/usr/lib/update-notifier/apt-check")
      updates = Facter::Util::Resolution.exec('/usr/lib/update-notifier/apt-check 2>&1')
      Integer(updates.strip.split(';')[0])
    end
  end
end
