require 'date'

class Token
  def self.get_stored(dwolla)
    path = ROOT_DIR + '/token.csv'
    if File.exist?(path) && CSV.read(path).length == 1
      CSV.read(path).first
    else
      make_new(dwolla)
      get_stored(dwolla)
    end
  end

  def self.fresh(dwolla)
    stored = get_stored(dwolla)
    elapsed = ((DateTime.now - DateTime.parse(stored[1])) * 86400).to_i
    if elapsed < 3000
      if elapsed > 600
        pid = Process.fork do
          make_new(dwolla)
          Process.exit
        end
        Process.detach pid
      end
      return dwolla.tokens.new({access_token: stored.first})
    else
      make_new(dwolla)
    end
  end

  def self.make_new(dwolla)
    token = dwolla.auths.client
    create!(token.access_token)
    token
  end

  def self.create!(token_string)
    CSV.open(ROOT_DIR + '/token.csv', 'w', converters: :date) do |csv|
      csv << [token_string, DateTime.now]
    end
  end
end
