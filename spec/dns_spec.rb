describe LinuxAdmin::Dns do
  RESOLV_CONF = <<DNS_END
# Generated by NetworkManager
search test.example.com test.two.example.com. example.com.
nameserver 192.168.1.2
nameserver 10.10.1.2
nameserver 192.168.252.3
DNS_END

  SEARCH_ORDER = %w(test.example.com test.two.example.com. example.com.)
  NAMESERVERS  = %w(192.168.1.2 10.10.1.2 192.168.252.3)

  NEW_CONF = <<DNS_END
search new.test.example.com other.test.example.com
nameserver 192.168.3.4
nameserver 10.10.11.12
DNS_END

  NEW_ORDER = %w(new.test.example.com other.test.example.com)
  NEW_NS    = %w(192.168.3.4 10.10.11.12)

  FILE = "/etc/dns_file"

  subject do
    allow(File).to receive(:read).and_return(RESOLV_CONF)
    described_class.new(FILE)
  end

  describe ".new" do
    it "sets the filename" do
      expect(subject.filename).to eq(FILE)
    end

    it "parses the nameservers" do
      expect(subject.nameservers).to eq(NAMESERVERS)
    end

    it "parses the search order" do
      expect(subject.search_order).to eq(SEARCH_ORDER)
    end
  end

  describe "#reload" do
    it "reloads the nameservers" do
      expect(subject.nameservers).to eq(NAMESERVERS)

      allow(File).to receive(:read).and_return(NEW_CONF)
      subject.reload

      expect(subject.nameservers).to eq(NEW_NS)
    end

    it "reloads the search order" do
      expect(subject.search_order).to eq(SEARCH_ORDER)

      allow(File).to receive(:read).and_return(NEW_CONF)
      subject.reload

      expect(subject.search_order).to eq(NEW_ORDER)
    end
  end

  describe "#save" do
    it "writes the correct contents" do
      expect(File).to receive(:write) do |file, contents|
        expect(file).to eq(subject.filename)
        expect(contents).to eq(NEW_CONF)
      end

      subject.search_order = NEW_ORDER
      subject.nameservers = NEW_NS
      subject.save
    end
  end
end
