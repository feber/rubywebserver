require 'json'
require 'ruby_gem_crud'
require 'sinatra/base'
require 'sinatoring'
require 'sinatoring/instrument'
require 'sinatoring/log'
require 'prometheus/middleware/collector'
require 'prometheus/middleware/exporter'
require 'uuid4r'

# Web maps each HTTP API call with logical method.
class Web < Sinatra::Base
  use Prometheus::Middleware::Collector
  use Prometheus::Middleware::Exporter

  # Initialize database service which is used in this class.
  # Decorates the service with metrics decorator from Sinatoring
  # 
  # @param [String] dbfile: database filename
  def initialize(dbfile)
    srv = RubyGemCrud.connect(dbfile)
    # decorator records all service methods for /metrics
    @service = Sinatoring::Decorator::Metrics.new(srv)
    Sinatoring::Instrument.init!
    super
  end

  # Set content type to json before each request
  before do
    content_type :json
  end

  get '/healthz' do
    if @service
      status 200
      'ok'
    else
      status 500
      'Not ok'
    end
  end

  # GET all available books
  # 
  # @return [Array(Book)] when the table is not empty,
  #      or [nil] otherwise
  get '/books' do
    # get context value from request headers
    ctx = Sinatoring.get_request_context(request)
    books = @service.all_books
    wrap_response do
      map_to_json(books)
    end
  end

  # POST a new book
  # 
  # @return [Book] when the insert operation was success,
  #      or [nil] otherwise
  post '/books' do
    request.body.rewind

    wrap_response do
      book = @service.insert_book(params['title'], params['category'])
      status 201
      book.to_json
    end
  end

  # GET a book determined by ID.
  # Error log will be written
  # if the book can't be found inside database.
  # 
  # @return [Book] when the record can be found,
  #      or [nil] otherwise.
  get '/books/:id' do
    wrap_response do
      start_time = Time.now
      # TODO: https://apidock.com/ruby/Time/to_f
      book = @service.find_book_by_id(params['id'].to_i)
      duration = ((Time.now.to_f - start_time.to_f) * 1000)
      puts duration.to_f

      if book.nil?
        logger = Sinatoring::Log.new
        request_id = UUID4R::uuid_v4
        message = 'fail'
        tags = ['RubyGemCrud::Service.find_book_by_id', 'asset', 'user_id']
        logger.error(request_id, message, tags, duration.to_i)

        status 400
      end

      book.to_json
    end
  end

  # POST updates a book determined by ID
  # Error log will be written
  # if the update operation failed.
  # 
  # @return [Book] when update operation success,
  #      or [nil] otherwise.
  post '/books/:id' do
    request.body.rewind

    wrap_response do
      book = @service.update_book(params['title'], params['category'], params['id'].to_i)
      if book.nil?
        logger = Sinatoring::Log.new
        request_id = UUID4R::uuid_v4
        message = 'fail'
        tags = ['RubyGemCrud::Service.find_book_by_id', 'asset', 'user_id']
        logger.error(request_id, message, tags, duration.to_i)

        status 400
      end
      book.to_json
    end
  end

  # DELETE deletes a book determined by ID
  delete '/books/:id' do
    request.body.rewind

    wrap_response do
      @service.delete_book(params['id'].to_i)
      status 204
    end
  end

  private

  # Map book list to json list
  #
  # @param [Array(Book)] books: book list to convert
  # @return [String] converted json string
  def map_to_json(books)
    if books.nil?
      return {
        data: []
      }.to_json
    end

    {
      data: books.map(&:to_json)
    }.to_json
  end

  # Wraps http response for handling exception
  #
  # returns [Sinatra::Response]
  def wrap_response
    block_given? ? yield : ''.to_json
  rescue TypeError => e
    status 400
    body({ message: e.message }.to_json)
  rescue ArgumentError => e
    status 400
    body({ message: e.message }.to_json)
  rescue StandardError => e
    status 500
    body({ message: e.message }.to_json)
  end
end
