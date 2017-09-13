## Getting Started

First, You need to set up some config in env.rb

```shell
mv env.rb.example
```

Write your dingtalk callback url and phone_number in `env.rb`

Then, you can run the sinatra app:

- Run in development with

```shell
ruby app.rb
```

- Run in production with

```shell
bundle exec rakeup config.ru -p 4567 -s thin -o 0.0.0.0
```

- Run in docker with

```shell
docker build -t aws-sns-to-dingtalk .
docker run -p 4567:4567 -d --name=aws-sns-to-dingtalk aws-sns-to-dingtalk:latest
```

## Reference

1. [Set up thin as web server](http://recipes.sinatrarb.com/p/deployment/lighttpd_proxied_to_thin)
2. [Something about gem thin](https://github.com/macournoyer/thin)
3. [How-To rackup](https://git.io/v5yJr)
4. [Intro to Sinatra](http://www.sinatrarb.com/intro.html)
5. [Dockerize sinatra app](http://blog.honeybadger.io/how-to-deploy-a-sinatra-app-in-docker-to-amazon-s-ec2-container-service/)
