require 'set'

class WelcomeController < ApplicationController
	$email_database = 
	{
	  "John Ferguson" => "john.ferguson@alphasights.com",
	  "Damon Aw" => "damon.aw@alphasights.com",
	  "Linda Li" => "linda.li@alphasights.com",
	  "Larry Page" => "larry.p@google.com",
	  "Sergey Brin" => "s.brin@google.com",
	  "Steve Jobs" => "s.j@apple.com"
	}

	def predict_email
		email_patterns = determineEmailPatterns()
		#Is this domain_name present in our dataset?
		if email_patterns.has_key?(params[:domain_name])
			predicted_emails = generatePredictedEmails(params[:first_name], params[:last_name], params[:domain_name], email_patterns[params[:domain_name]])
		else
			predicted_emails = generatePredictedEmails(params[:first_name], params[:last_name], params[:domain_name], nil)
		end
		render :text => predicted_emails.to_a

	end

	private
		def determineEmailPatterns ()
			result = {}
			$email_database.each do |name, email|
			username, domain_name = email.split("@")
			prediction_type = determinePatternFromDomain(username)
				if result.has_key?(domain_name)
					s1 = result[domain_name]
					s1.add(prediction_type)
					result[domain_name] = s1
				else 
					s1 = Set.new
					s1.add(prediction_type)
					result[domain_name] = s1
				end
			end
			result
		end

		def determinePatternFromDomain(username)
			result = ""
			first_name,last_name = username.split(".")
			if first_name.length > 1
				if last_name.length > 1
					result = :first_name_dot_last_name
				else
					result = :first_name_dot_last_initial
				end
			else
				if last_name.length > 1
					result = :first_initial_dot_last_name
				else
					result = :first_initial_dot_last_initial
				end
			end		
			result
		end

		def generatePredictedEmails(first_name, last_name, domain_name, prediction_formats = nil)
			result = Set.new
			if prediction_formats.nil?
				# Generate all possible email combinations
				result.add(first_name.downcase + "." + last_name.downcase + "@" + domain_name.downcase);
				result.add(first_name[0].downcase + "." + last_name.downcase + "@" + domain_name.downcase);
				result.add(first_name.downcase + "." + last_name[0].downcase + "@" + domain_name.downcase);
				result.add(first_name[0].downcase + "." + last_name[0].downcase + "@" + domain_name.downcase);
			else
				prediction_formats.each do |prediction_type|
					case prediction_type
					when :first_name_dot_last_name
						result.add(first_name.downcase + "." + last_name.downcase + "@" + domain_name.downcase);
					when :first_name_dot_last_initial
						result.add(first_name.downcase + "." + last_name[0].downcase + "@" + domain_name.downcase);
					when :first_initial_dot_last_name
						result.add(first_name[0].downcase + "." + last_name.downcase + "@" + domain_name.downcase);
					when :first_initial_dot_last_initial
						result.add(first_name[0].downcase + "." + last_name[0].downcase + "@" + domain_name.downcase);
					end
				end
			end
			result
		end
end
