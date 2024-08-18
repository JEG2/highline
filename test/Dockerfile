FROM ruby

WORKDIR /highline


RUN bash -ec 'apt update; apt -y install cmake'

ADD Gemfile highline.gemspec .git* ./
ADD lib/highline/version.rb ./lib/highline/version.rb
RUN bundle install

ADD . .

ENTRYPOINT ["bundle", "exec"]
CMD ["bash", "-ec", "rake test; rake acceptance; pronto run"]
