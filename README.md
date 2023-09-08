# FamilyTree
FamilyTree - A command line system which can help a user define their family tree, written in Elixir.

## Installation
- Make sure you have Elixir and Mix tool installed on your system.
- Checkout project from this repository.
- Open terminal and change to project directory.
- Use `mix escript.build` to compile. To compile in release mode, use `MIX_ENV=prod mix escript.build`.
- Run using the generated `family_tree` executable in the project directory.

## Usage
- `family_tree -h` or `family_tree --help`: Display help section.
- `family_tree add person <person>`: Adds a person named \<person> to the family tree.
- `family_tree add relationship <relation_1> <relation_2>`: Defines a relationship pair of complements and stores it in relationship vocabulary. E.g. `family_tree add relationship father child` defines and stores a father-child relationship.
- `family_tree connect <person_1> as <relation> of <person_2>`: Creates a \<relation> between \<person_1> and \<person_2>. E.g. If we define a father-child relationship in the previous step and then use `family_tree connect John as father of James`, then John is father of James and James is child of John.
- `family_tree count <relation> of <person>`: Returns count of all \<relation> of a person named \<person>. E.g. To get count of all children of John, we'll use `family_tree count child of John`.
- `family_tree <relation> of <person>`: Returns the list of persons that are related to \<person> by the relation \<relation>.

Here's a sample usage to get started:
```sh
# Some relationship rules are defined first
./family_tree set relationship parent father gender:male
./family_tree set relationship parent mother gender:female
./family_tree set relationship child son gender:male
./family_tree set relationship child daughter gender:female

# Let's add some people
./family_tree add person "Naruto Uzumaki" gender:male
./family_tree add person "Kushina Uzumaki" gender:female
./family_tree add person "Minato Namikaze" "gender:male;occupation:4th Hokage"

# Let's relate people now (Relationship exists between 2 persons for now)
./family_tree connect "Naruto Uzumaki" as child of "Kushina Uzumaki"
./family_tree connect "Naruto Uzumaki" as son of "Minato Namikaze"
```

Based on above, you can ask questions like the following:
```sh
./family_tree mother of "Naruto Uzumaki"
./family_tree count sons of "Kushina Uzumaki"
./family_tree count children of "Kushina Uzumaki"
./family_tree count daughter of "Minato Namikaze"
```

## Limitations
- Since I wasn't sure about using external dependencies, I decided to use built-in Elixir stuff only. Also, escripts do not support accessing content in priv directories. That rules out serving static files, running migrations, etc. right out of the box. SQLite would've simplified this problem a lot, but DETS is good enough too.
- Didn't add any deletion commands, because its easier to start from scratch in-case something goes wrong, since we're using this as a command-line tool. Also, because if I did, I'll have to cascade delete stuff if a relation or a person is deleted to maintain schema consistency - which is another good  reason to use SQLite.

## Feedback
Any feedback is highly appreciated, please raise an issue in the Issues section. Thanks!