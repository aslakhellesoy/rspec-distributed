describe "first" do
  it "example a" do
    sleep 1
  end

  it "example b" do
    sleep 1
  end
end

describe "second" do
  it "example c" do
    sleep 1
    raise "error"
  end

  it "example d" do
    sleep 1
  end
end

describe "third" do
  it "example e" do
    sleep 1
  end

  it "example f" do
    sleep 1
  end
end

describe "fourth" do
  it "example g" do
    sleep 1
  end

  it "example h" do
    sleep 0.5
    1.should == 2
  end

  it "example i" do
    sleep 0.5
  end
end
