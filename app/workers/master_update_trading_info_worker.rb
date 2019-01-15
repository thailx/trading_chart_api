class MasterUpdateTradingInfoWorker
  include Sidekiq::Worker

  def perform(*args)
    # Do something
    count_crypto = cryptocurrencies.count
    total_pages = (count_crypto / 10) + 1
    total_pages.times do |i|
      offset = i * 10
      UpdateCryptoTradingInfoWorker.perform_in(offset.minutes.from_now, offset)
    end
  end
end