require 'sqlite3'
require 'singleton'

class QuestionsDatabase < SQLite3::Database
  include Singleton

  def initialize
    super('questions.db')
    self.type_translation = true
    self.results_as_hash = true
  end
end

class Users
  attr_accessor :user_id, :fname, :lname

  def self.all
    data = QuestionsDatabase.instance.execute("SELECT * FROM users")
    data.map { |datum| Users.new(datum) }
  end

  def self.find_by_id(user_id)
    data = QuestionsDatabase.instance.execute(<<-SQL, user_id)
      SELECT
        *
      FROM
        users
      WHERE
        user_id = ?
    SQL
    data.map { |datum| Users.new(datum) }
  end

  def self.find_by_fname(fname)
    data = QuestionsDatabase.instance.execute(<<-SQL, fname)
      SELECT
        *
      FROM
        users
      WHERE
        users.fname LIKE ?
    SQL
    data.map { |datum| Users.new(datum) }
  end

  def initialize(options)
    @user_id = options['user_id']
    @fname = options['fname']
    @lname = options['lname']
  end

  def self.create(fname, lname)
    options = {}
    options['fname'] = fname
    options['lname'] = lname
    yuze = Users.new(options)
    raise "#{yuze} already in database" if yuze.user_id
    QuestionsDatabase.instance.execute(<<-SQL, yuze.fname, yuze.lname)
      INSERT INTO
        users (fname, lname)
      VALUES
        (?, ?)
    SQL
    yuze.user_id = QuestionsDatabase.instance.last_insert_row_id
  end

  def create
    raise "#{self} already in database" if self.user_id
    QuestionsDatabase.instance.execute(<<-SQL, self.fname, self.lname)
      INSERT INTO
        users (fname, lname)
      VALUES
        (?, ?)
    SQL
    self.user_id = QuestionsDatabase.instance.last_insert_row_id
  end

  def update
    raise "#{self} not in database" unless self.user_id
    QuestionsDatabase.instance.execute(<<-SQL, self.fname, self.lname, self.user_id)
      UPDATE
        users
      SET
        fname = ?, lname = ?
      WHERE
        user_id = ?
    SQL
  end

  def average_karma
    data = QuestionsDatabase.instance.execute(<<-SQL, self.user_id)
      SELECT
        COUNT(question_likes.question_like_id)
      FROM
        question_likes
      JOIN users ON users.user_id = question_likes.user_id
      JOIN questions ON questions.question_id = question_likes.question_id
      WHERE
        question_likes.user_id = ?
      GROUP BY 
        question_likes.question_id
    SQL
    data[0]
    # data.map { |datum| Users.new(datum) }
  end
end

class Questions
  attr_accessor :question_id, :title, :body, :user_id

  def self.all
    data = QuestionsDatabase.instance.execute("SELECT * FROM questions")
    data.map { |datum| Questions.new(datum) }
  end

  def self.find_by_id(question_id)
    data = QuestionsDatabase.instance.execute(<<-SQL, question_id)
      SELECT
        *
      FROM
        questions
      WHERE
        question_id = ?
    SQL
    data.map { |datum| Questions.new(datum) }
  end

  def self.find_by_user_id(user_id)
    data = QuestionsDatabase.instance.execute(<<-SQL, user_id)
      SELECT
        *
      FROM
        questions
      WHERE
        user_id = ?
    SQL
    data.map { |datum| Questions.new(datum) }
  end

  def self.find_by_name(name)
    data = QuestionsDatabase.instance.execute(<<-SQL, name)
      SELECT
        *
      FROM
        questions
      JOIN users ON users.user_id = questions.user_id
      WHERE
        users.fname OR users.lname  LIKE ?
        --OR users.lname LIKE ?
    SQL
    data.map { |datum| Questions.new(datum) }
  end

  def initialize(options)
    @question_id = options['question_id']
    @title = options['title']
    @body = options['body']
    @user_id = options['user_id']
  end

  def self.create(title, body, user_id)
    options = {}
    options['title'] = title
    options['body'] = body
    options['user_id'] = user_id
    options
    quest = Questions.new(options)
    raise "#{quest} already in database" if quest.question_id
    QuestionsDatabase.instance.execute(<<-SQL, quest.title, quest.body, quest.user_id)
      INSERT INTO
        questions (title, body, user_id)
      VALUES
        (?, ?, ?)
    SQL
    quest.question_id = QuestionsDatabase.instance.last_insert_row_id
  end

  def create
    raise "#{self} already in database" if self.question_id
    QuestionsDatabase.instance.execute(<<-SQL, self.title, self.body, self.user_id)
      INSERT INTO
        questions (title, body, user_id)
      VALUES
        (?, ?, ?)
    SQL
    self.question_id = QuestionsDatabase.instance.last_insert_row_id
  end

  def update
    raise "#{self} not in database" unless self.question_id
    QuestionsDatabase.instance.execute(<<-SQL, self.title, self.body, self.user_id, self.question_id)
      UPDATE
        questions
      SET
        title = ?, body = ?, user_id = ?
      WHERE
        question_id = ?
    SQL
  end
end

class QuestionLikes
  attr_accessor :question_like_id, :question_id, :user_id

  def self.all
    data = QuestionsDatabase.instance.execute("SELECT * FROM question_likes")
    data.map { |datum| QuestionLikes.new(datum) }
  end

  def initialize(options)
    @question_like_id = options['question_like_id']
    @question_id = options['question_id']
    @user_id = options['user_id']
  end

  def self.find_most_liked_question
    data = QuestionsDatabase.instance.execute(<<-SQL)
      SELECT
        question_id
      FROM
        question_likes
      GROUP BY
        question_id
      ORDER BY
        COUNT(question_like_id) DESC
      LIMIT 1
    SQL
    # data.map { |datum| QuestionLikes.new(datum) }
    q_id = data[0]['question_id']
    Questions.find_by_id(q_id)
  end

  def self.create(question_id, user_id)
    options = {}
    options['question_id'] = question_id
    options['user_id'] = user_id
    options
    quest = QuestionLikes.new(options)
    raise "#{quest} already in database" if quest.question_like_id
    QuestionsDatabase.instance.execute(<<-SQL, quest.question_id, quest.user_id)
      INSERT INTO
        question_likes (question_id, user_id)
      VALUES
        (?, ?)
    SQL
    quest.question_like_id = QuestionsDatabase.instance.last_insert_row_id
  end
end

