# frozen_string_literal: true

class CustomerSuccessBalancing
  MAX_CUSTOMERS_WITH_SAME_SCORE = 1

  def initialize(customer_success, customers, away_customer_success)
    @customer_success = customer_success
    @customers = customers
    @away_customer_success = away_customer_success
  end

  # Returns the ID of the customer success with most customers
  def execute
    customers_scores_by_cs = group_customers_scores_by_cs

    find_cs_id_with_more_customers(customers_scores_by_cs)
  end

  private

  def group_customers_scores_by_cs
    delete_cs_away
    @customer_success.sort_by! { |cs| cs[:score] }
    customers_scores_by_cs = Hash[@customer_success.map { |cs| [cs, []] }]

    @customers.each do |customer|
      customers_scores = customers_scores_by_cs[
        @customer_success.find { |cs| customer[:score] <= cs[:score] }
      ]
      customers_scores&.push(customer[:score])
    end

    customers_scores_by_cs
  end

  def delete_cs_away
    @away_customer_success.each do |id|
      @customer_success.delete_if { |cs| cs[:id] == id }
    end
  end

  def find_cs_id_with_more_customers(customers_scores_by_cs)
    total_of_customers_by_cs_id = total_of_customers_by_cs_id(customers_scores_by_cs)
    cs_id_with_more_customers = cs_id_with_more_customers(total_of_customers_by_cs_id)
    highest_total_of_customers_scores = total_of_customers_by_cs_id[cs_id_with_more_customers]

    return 0 if cs_id_with_more_customers.nil? ||
                highest_total_of_customers_scores.zero? ||
                draw_between_cs?(total_of_customers_by_cs_id, highest_total_of_customers_scores)

    cs_id_with_more_customers
  end

  def draw_between_cs?(total_of_customers_by_cs_id, highest_total_of_customers_scores)
    total_of_customers_by_cs_id.values.count(highest_total_of_customers_scores) > MAX_CUSTOMERS_WITH_SAME_SCORE
  end

  def total_of_customers_by_cs_id(customers_scores_by_cs)
    total_of_customers_by_cs_id = {}

    customers_scores_by_cs.each do |cs, customers_score|
      total_of_customers_by_cs_id[cs[:id]] = customers_score.count
    end

    total_of_customers_by_cs_id
  end

  def cs_id_with_more_customers(total_of_customers_by_cs_id)
    customers_count = 0
    customer_id = nil

    total_of_customers_by_cs_id.each do |cs_id, total_of_costumers|
      if total_of_costumers >= customers_count
        customer_id = cs_id
        customers_count = total_of_costumers
      end
    end

    customer_id
  end
end
