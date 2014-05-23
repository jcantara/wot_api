module WotApi

  class Player < Base
    attr_reader :nickname, :account_id

    def initialize(params={})
      ArgumentError.new("application_id is required") unless self.class.default_params[:application_id]
      @nickname = params['nickname']
      @account_id = params['account_id']
    end

    class << self

      def find_all_by_name_like(query)
        result = self.post('/wot/account/list/', body: {search: query})
        data = result['data']
        if data
          data.map{|d| self.new(d)}
        else
          []
        end
      end

    end

  end

end
