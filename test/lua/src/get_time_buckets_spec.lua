require "get_time_buckets"

describe("get time buckets for last 24 hours", function ()
  it("should return a table with strings", function ()
    local result = get_time_buckets(1678991574677)
    assert.are.same({
      "2023-03-15-19",
      "2023-03-15-20",
      "2023-03-15-21",
      "2023-03-15-22",
      "2023-03-15-23",
      "2023-03-16-00",
      "2023-03-16-01",
      "2023-03-16-02",
      "2023-03-16-03",
      "2023-03-16-04",
      "2023-03-16-05",
      "2023-03-16-06",
      "2023-03-16-07",
      "2023-03-16-08",
      "2023-03-16-09",
      "2023-03-16-10",
      "2023-03-16-11",
      "2023-03-16-12",
      "2023-03-16-13",
      "2023-03-16-14",
      "2023-03-16-15",
      "2023-03-16-16",
      "2023-03-16-17",
      "2023-03-16-18"
    }, result)
  end)
end)