require "net/http"
require "json"
require "uri"

namespace :ai do
  desc "Check AI chat runtime and Nano-friendly Ollama configuration"
  task nano_check: :environment do
    url = ENV.fetch("OLLAMA_URL", "http://localhost:11434")
    model = ENV.fetch("OLLAMA_MODEL", "llama3.2:1b")
    num_ctx = ENV.fetch("OLLAMA_NUM_CTX", "1024").to_i
    num_predict = ENV.fetch("OLLAMA_NUM_PREDICT", "384").to_i
    temperature = ENV.fetch("OLLAMA_TEMPERATURE", "0.3").to_f

    puts "AI Nano Check"
    puts "------------"
    puts "OLLAMA_URL=#{url}"
    puts "OLLAMA_MODEL=#{model}"
    puts "OLLAMA_NUM_CTX=#{num_ctx}"
    puts "OLLAMA_NUM_PREDICT=#{num_predict}"
    puts "OLLAMA_TEMPERATURE=#{temperature}"
    puts

    warnings = []
    failures = []

    nano_safe_models = %w[
      llama3.2:1b
      qwen2.5:1.5b
      phi3:mini
    ]

    unless nano_safe_models.include?(model)
      warnings << "Configured model '#{model}' is not in the Nano-safe defaults (#{nano_safe_models.join(", ")})."
    end

    warnings << "OLLAMA_NUM_CTX is high for Nano (recommended <= 2048)." if num_ctx > 2048
    warnings << "OLLAMA_NUM_PREDICT is high for Nano (recommended <= 512)." if num_predict > 512
    warnings << "OLLAMA_TEMPERATURE is high for deterministic formatting (recommended <= 0.5)." if temperature > 0.5

    begin
      base_uri = URI(url)
      tags_uri = URI.join(url.end_with?("/") ? url : "#{url}/", "api/tags")

      http = Net::HTTP.new(tags_uri.host, tags_uri.port)
      http.use_ssl = tags_uri.scheme == "https"
      http.open_timeout = 3
      http.read_timeout = 5

      request = Net::HTTP::Get.new(tags_uri)
      response = http.request(request)

      if response.is_a?(Net::HTTPSuccess)
        body = JSON.parse(response.body)
        models = Array(body["models"]).map { |m| m["name"] }.compact

        puts "[OK] Ollama reachable at #{base_uri}"

        if models.include?(model)
          puts "[OK] Model installed: #{model}"
        else
          failures << "Model '#{model}' is not installed in Ollama. Run: ollama pull #{model}"
        end
      else
        failures << "Ollama responded with HTTP #{response.code} at #{tags_uri}"
      end
    rescue StandardError => e
      failures << "Cannot connect to Ollama at #{url}: #{e.class} - #{e.message}"
    end

    puts
    if warnings.empty?
      puts "[OK] No Nano-safety warnings."
    else
      puts "[WARN] Nano-safety warnings:"
      warnings.each { |w| puts "- #{w}" }
    end

    if failures.empty?
      puts "[OK] AI runtime checks passed."
    else
      puts "[FAIL] AI runtime failures:"
      failures.each { |f| puts "- #{f}" }
      exit 1
    end
  end
end
