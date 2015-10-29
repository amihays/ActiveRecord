In Active Record Lite, I built the basic functionality of Rails' Active Record using Ruby's metaprogramming capabilities. I started by building the SQLObject class, which is analogous to Rails' ActiveRecord::Base.

### Phase I
In Phase I, instances of SQLObject are given getter and setter methods for each column name in the table associated with their model. SQLObject::all returns all records in a table. SQLObject::find allows lookup of single record by primary key. SQLObject#update and SQLObject#insert methods allow changes made to SQLObject instances to be stored in the table, and the SQLObject#save method calls update or insert depending on whether or not the object has an ID.
[See Code][phase-one]

### Phase II
During Phase II, I added the SQLObject::where method to allow searching through the table associated with a model subclass of SQLObject.
[See Code][phase-two]

### Phase III
During Phase III, I define associations between models by adding a BelongsToOptions class and a HasManyOptions class which set up the primary_key, foreign_key and class_name (both take an options hash on initialize to override the defaults). BelongsToOptions and HasManyOptions are both subclasses of AssocOptions, and they inherit two methods: #model_class (returns the class object from the class_name string) and #table_name (finds the table associated with the model_class). Finally, I added belongs_to and has_many class methods to the model, which defines a new instance method - the name passed in as a paramenter.
[See Code][phase-three]

### Phase IV
I added a has_one_through association by adding an assoc_options hash to store the belongs_to association options for each model, and using these options to make a database query when the association is called on an instance of the model.
[See Code][phase-four]

[phase-one]: ./lib/01_sql_object.rb
[phase-two]: ./lib/02_searchable.rb
[phase-three]: ./lib/03_associatable.rb
[phase-four]: ./lib/04_associatable2.rb
