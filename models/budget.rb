require_relative('../db/sql_runner.rb')

class Budget

  attr_writer :budget
  attr_reader :id, :month, :month_name, :budget, :year

  def initialize(options)
    @id = options['id'].to_i if options['id']
    @month = options['month'].to_i
    @month_name = options['month_name']
    @budget = options['budget'].to_f
    @year = options['year']
  end

  # Create
  def save()
    sql = "INSERT INTO budgets (month, month_name, budget, year)
    VALUES ($1, $2, $3, $4)
    RETURNING id;"
    values = [@month, @month_name, @budget, @year]
    result = SqlRunner.run(sql, values) # array of hash with id number.
    id_hash = result.first
    @id = id_hash['id'].to_i
  end

  # Read
  def self.find(id)
    sql = "SELECT * FROM budgets WHERE id = $1;"
    values = [id]
    result = SqlRunner.run(sql, values) # array of hash with budget information.
    return Budget.new(result.first) # creates Budget object of found budget.
  end

  def self.find_year_month(year, month)
    sql = "SELECT * FROM budgets WHERE (year, month) = ($1, $2);"
    values = [year, month]
    result = SqlRunner.run(sql, values) # array of one budget hash
    return Budget.new(result.first)
  end

  def self.all()
    sql = "SELECT * FROM budgets ORDER BY id;"
    results = SqlRunner.run(sql) # array of budget hashes.
    return results.map { |budget_hash| Budget.new(budget_hash) } # array of Budget objects.
  end

  def self.all_year(year)
    sql = "SELECT * FROM budgets WHERE year = $1 ORDER BY id;"
    values = [year]
    results = SqlRunner.run(sql, values) # array of budget hashes.
    return results.map { |budget_hash| Budget.new(budget_hash) } # array of Budget objects.
  end

  # Update - will only ever be allowed to update values, not month names (these are set).
  def update()
    sql = "UPDATE budgets
    SET budget = $1
    WHERE id = $2;"
    values = [@budget, @id]
    SqlRunner.run(sql, values)
  end

  # Will never delete a budget month so don't need delete functions.

  # Method to bring back total budget of a specified year.
  def self.total_year(my_year)
    all_budgets = Budget.all()
    budget_year_total = 0
    for entry in all_budgets
      if entry.year == my_year.to_s
        budget_year_total += entry.budget.to_f
      end
    end
    return budget_year_total.round(2)
  end

  def self.total_month(my_year, my_month)
    all_budgets = Budget.all()
    budget_month_total = 0
    for entry in all_budgets
      if entry.year == my_year.to_s && entry.month_name == my_month.to_s
        budget_month_total += entry.budget.to_f
      end
    end
    return budget_month_total.round(2)
  end

end
