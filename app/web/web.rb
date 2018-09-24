require 'sinatra/base'
require 'json'
require 'ruby_gem_crud'

  class Web < Sinatra::Base
    def initialize(dbfile)
      @service = RubyGemCrud.connect(dbfile)
      super
    end

    # set content type
    before do
      content_type :json
    end

    get '/healthz' do
      if @service
        status 200
        'ok'
      else
        status 500
        'I\'m not okay :/'
      end
    end

    get '/books' do
      books = @service.all_books
      res = []
      wrap_response do
        map_to_json(books)
      end
    end

    post '/books' do
      request.body.rewind

      wrap_response do
        book = @service.insert_book(params['title'], params['category'])
        status 201
        book.to_json
      end
    end

    get '/books/:id' do
      wrap_response do
        book = @service.find_book_by_id(params['id'].to_i)
        book.to_json
      end
    end

    post '/books/:id' do
      request.body.rewind

      wrap_response do
        book = @service.update_book(params['title'], params['category'], params['id'].to_i)
        book.to_json
      end
    end

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
