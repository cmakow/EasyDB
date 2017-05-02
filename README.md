# RubyRM -- A Lightweight Object-Relational Mapping tool for Rails Projects

RubyRM is an Object-Relational Mapping tool written in Ruby for Rails projects. It allows users to connect classes to relational database tables with very little configuration. Through the SQLObject class, users can easily connect their rails models to the tables behind them, as well as connecting the models to each other via associations.

## SQLObject

### Key Features

User models that extend SQLObject will have access to a number of methods:

- New instances of the model can be initiated with a parameter hash (e.g. `dog = Dog.new(name: 'Buddy', color: 'brown')`). The keys must correspond to columns in the connected database table.
- Through the searchable module, it allows users to search by any column of the table for a specific value.
- Allows the creation of associations between models through 'belongs_to' and 'has_many'.
- Finalize, when called in the model definition, will create attribute accessors for all of the columns in the associated database.
- Calling save will either update or insert a record based on the presence of an id and thus can be called for both purposes.

### Example Usage

* To get the basic functionality, simply have a model extend the SQLObject class. To set up accessors, simply call finalize! in the class definition.

```ruby
class Dog < SQLObject
  finalize!
end
```

* This will give access to a number of basic methods for looking up data in the associated database table name, which is automatically set to "dogs" by default. The table may be set up like so:

```sql
CREATE TABLE dogs (
  id INTEGER PRIMARY KEY,
  name VARCHAR(255) NOT NULL,
  owner_id INTEGER,

  FOREIGN KEY(owner_id) REFERENCES human(id)
);
```

* This will give access to a number of methods including `Dog#name`, `Dog#name=(new_name)` and `Dog::all`.

* It will also give access to the search method where, which has been set up to return a relation object that allows chaining the where method together (e.g. `Dog.where(owner_id: 3).where(name: 'Buddy')`).

* Another feature is associations, which may be set up as follows:

```ruby
class Dog < SQLObject
  belongs_to :human, foreign_key: :owner_id

  has_many :toys, foreign_key: :dog_id

  finalize!
end
```

* This will allow functions in the name of the associated class to be called on `Dog` objects (`Dog#human`, `Dog#toys`)

## Configuring the Database

SQLObject uses a DBConnection class in order to connect to the SQLite database. To configure it for use with a different database, all one will need to do is create a new SQL file, create the database from it, and pass those files into the constants a the top of the file. Then, run DBConnection.reset in order to initialize DBConnection with the new database.

```ruby
TEST_SQL_FILE = File.join(ROOT_FOLDER, 'insert_your_sql.sql')
TEST_DB_FILE = File.join(ROOT_FOLDER, 'insert_your_db.db')

DBConnection.reset
```

You're good to go!

## Pipeline
* Package RubyRM as a gem
* Implement more features (improve `SQLObject::where`, `has_many :through`)
