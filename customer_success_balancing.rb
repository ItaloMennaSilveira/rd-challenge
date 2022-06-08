require 'minitest/autorun'
require 'timeout'

class CustomerSuccessBalancing
  def initialize(customer_success, customers, away_customer_success)
    @customer_success = customer_success
    @customers = customers
    @away_customer_success = away_customer_success
  end

  # Returns the ID of the customer success with most customers
  def execute
    cs_with_customers_scores = associate_customer_score_to_cs

    find_cs_id_with_more_customers(cs_with_customers_scores)
  end

  private

  def associate_customer_score_to_cs
    delete_cs_away
    @customer_success.sort_by! { |cs| cs[:score] }
    cs_with_customers_scores = Hash[@customer_success.map { |cs| [cs, []] }]

    @customers.each do |customer|
      cs_scores = cs_with_customers_scores[@customer_success.find { |cs| customer[:score] <= cs[:score] }]
      cs_scores&.push(customer[:score])
    end

    cs_with_customers_scores
  end

  def delete_cs_away
    @away_customer_success.each do |id|
      @customer_success.delete_if { |cs| cs[:id] == id }
    end
  end

  def find_cs_id_with_more_customers(cs_with_customers_scores)
    total_of_customers_by_cs_id = {}

    cs_with_customers_scores.each do |cs, customers_score|
      total_of_customers_by_cs_id[cs[:id]] = customers_score.count
    end

    customers_count = 0
    last_customer_id = nil
    total_of_customers_by_cs_id.each do |cs_id, total_of_costumers|
      if total_of_costumers >= customers_count
        last_customer_id = cs_id
        customers_count = total_of_costumers
      end
    end

    total_of_scores = total_of_customers_by_cs_id[last_customer_id]

    return 0 if total_of_scores.zero? || draw_between_cs?(total_of_customers_by_cs_id, total_of_scores)

    last_customer_id
  end

  def draw_between_cs?(total_of_customers_by_cs_id, total_of_scores)
    total_of_customers_by_cs_id.values.count(total_of_scores) >= 2
  end
end

class CustomerSuccessBalancingTests < Minitest::Test
  def test_scenario_one
    balancer = CustomerSuccessBalancing.new(
      build_scores([60, 20, 95, 75]),
      build_scores([90, 20, 70, 40, 60, 10]),
      [2, 4]
    )
    assert_equal 1, balancer.execute
  end

  def test_scenario_two
    balancer = CustomerSuccessBalancing.new(
      build_scores([11, 21, 31, 3, 4, 5]),
      build_scores([10, 10, 10, 20, 20, 30, 30, 30, 20, 60]),
      []
    )
    assert_equal 0, balancer.execute
  end

  def test_scenario_three
    balancer = CustomerSuccessBalancing.new(
      build_scores(Array(1..999)),
      build_scores(Array.new(10000, 998)),
      [999]
    )
    result = Timeout.timeout(1.0) { balancer.execute }
    assert_equal 998, result
  end

  def test_scenario_four
    balancer = CustomerSuccessBalancing.new(
      build_scores([1, 2, 3, 4, 5, 6]),
      build_scores([10, 10, 10, 20, 20, 30, 30, 30, 20, 60]),
      []
    )
    assert_equal 0, balancer.execute
  end

  def test_scenario_five
    balancer = CustomerSuccessBalancing.new(
      build_scores([100, 2, 3, 3, 4, 5]),
      build_scores([10, 10, 10, 20, 20, 30, 30, 30, 20, 60]),
      []
    )
    assert_equal 1, balancer.execute
  end

  def test_scenario_six
    balancer = CustomerSuccessBalancing.new(
      build_scores([100, 99, 88, 3, 4, 5]),
      build_scores([10, 10, 10, 20, 20, 30, 30, 30, 20, 60]),
      [1, 3, 2]
    )
    assert_equal 0, balancer.execute
  end

  def test_scenario_seven
    balancer = CustomerSuccessBalancing.new(
      build_scores([100, 99, 88, 3, 4, 5]),
      build_scores([10, 10, 10, 20, 20, 30, 30, 30, 20, 60]),
      [4, 5, 6]
    )
    assert_equal 3, balancer.execute
  end

  private

  def build_scores(scores)
    scores.map.with_index do |score, index|
      { id: index + 1, score: score }
    end
  end
end
