class Dog
  attr_accessor :id, :name, :breed

  def initialize(props={})
    @id = props[:id]
    @name = props[:name]
    @breed = props[:breed]
  end

  def self.create_table
    sql = <<-SQL
    CREATE TABLE IF NOT EXISTS dogs (
      id INTEGER PRIMARY KEY,
      name TEXT,
      breed TEXT
    )
    SQL
    DB[:conn].execute(sql)
    end

  def self.drop_table
    sql = <<-SQL
    DROP TABLE dogs
    SQL
    DB[:conn].execute(sql)
  end

  def save
    sql = <<-SQL
      INSERT INTO dogs (name, breed) VALUES (?,?)
    SQL
    DB[:conn].execute(sql, self.name, self.breed)
    self.id = DB[:conn].execute("SELECT last_insert_rowid() from DOGS")[0][0]
    self
  end

  def self.create(hash)
    new_dog = Dog.new(hash)
    new_dog.save
  end

  def self.find_by_id(id)
    sql = <<-SQL
    SELECT * FROM dogs where id = ?
    SQL
    found_dog = DB[:conn].execute(sql, id)[0]
    new_hash = {:id => found_dog[0], :name => found_dog[1], :breed => found_dog[2]}
    Dog.new(new_hash)
  end

  def self.find_or_create_by(name:, breed:)
    sql = <<-SQL
      SELECT * FROM dogs where name = ? AND breed = ?
    SQL
    found_dog = DB[:conn].execute(sql, name, breed)
    if !found_dog.empty?
      new_dog = Dog.new({:id => found_dog[0][0], :name => found_dog[0][1], :breed => found_dog[0][2]})
    else
      new_dog = self.create(name: name, breed: breed)
    end
    new_dog
  end

  def self.new_from_db(row)
    Dog.new({:id => row[0], :name => row[1], :breed => row[2]})
  end

  def self.find_by_name(name)
    sql =<<-SQL
      SELECT * FROM dogs where name = ?
    SQL
    found_dog = DB[:conn].execute(sql, name)[0]
    Dog.new_from_db(found_dog)
  end

  def update
    sql = <<-SQL
     UPDATE dogs SET name = ?, breed = ? WHERE id = ?
    SQL
    DB[:conn].execute(sql, self.name, self.breed, self.id)
  end

end
