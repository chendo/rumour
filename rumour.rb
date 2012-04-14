require 'dbus'
require 'json'
require 'pp'
require 'sinatra'
require 'sinatra/json'

set :json_encoder, JSON

get '/' do
  <<-HTML
  <html>
  <head>
    <title>Mumble Stats</title>
    <script src="https://ajax.googleapis.com/ajax/libs/jquery/1.7.1/jquery.min.js"></script>
    <script src="https://raw.github.com/janl/mustache.js/master/mustache.js"></script>
  </head>
  <body>
    <script type="text/javascript">
      var partials = {
        channel: "<li>                \\
            <strong>{{name}}</strong> \\
            <ul class=\\"users\\">        \\
              {{#users}}              \\
                <li>{{name}}</li>     \\
              {{/users}}              \\
            </ul>                     \\
            <ul>                      \\
              {{#children}}           \\
                {{>channel}}          \\
              {{/children}}           \\
            </ul>                     \\
          </li>"
      };
      var template = "{{#servers}}                                   \\
          <div class=\\"server\\">                                     \\
            <strong>{{root_channel.name}}</strong>                   \\
            <ul>                                                     \\
              {{#root_channel.children}}                             \\
                {{>channel}}                                         \\
              {{/root_channel.children}}                             \\
              <ul class=\\"users\\">                                   \\
                {{#root_channel.users}}                              \\
                  <li>{{name}} {{#talking}}talking{{/talking}} </li> \\
                {{/root_channel.users}}                              \\
              </ul>                                                  \\
            </ul>                                                    \\
          </div>                                                     \\
        {{/servers}}";

      $(function () {
        setInterval(function () {
          $.get('/servers.json', function (data) {
            $('#mumble').html(
              Mustache.render(template, data, partials)
            );
          });
        }, 2000);
      })
    </script>
    <div id="mumble">

    </div>
  </body>
  </html>
  HTML
end

get '/servers.json' do
  headers 'Access-Control-Allow-Origin' => '*', 'Cache-Control' => 'max-age=1, public'
  json :servers => Murmur.instance.servers
end

class Murmur
  MURMUR_DBUS_IDENTIFIER = "net.sourceforge.mumble.murmur"
  MURMUR_META_INTERFACE = "net.sourceforge.mumble.Meta"
  MURMUR_INTERFACE = "net.sourceforge.mumble.Murmur"

  def self.instance
    @instance ||= new
  end

  def service
    @service ||= begin
      dbus = DBus::SystemBus.instance
      dbus.service(MURMUR_DBUS_IDENTIFIER)
    end
  end

  def servers
    root_object = service.object("/")

    root_object.introspect
    root_object.default_iface = MURMUR_META_INTERFACE

    root_object.getBootedServers.flatten.map do |server_index|
      Server.new(service.object("/#{server_index}"))
    end

  end

  class Server
    def initialize(server_object)
      @server = server_object
      @server.introspect
      @server.default_iface = MURMUR_INTERFACE
    end

    def root_channel
      users = get_users
      channels = {}
      @server.getChannels.first.map do |channel_data|
        channel = Channel.new(*channel_data)
        channels[channel.id] = channel
        channels[channel.parent_id].children << channel if channel.parent_id != -1

        channel.users = users.select { |user| user.channel_id == channel.id }
      end
      channels[0]
    end

    def to_json(*args)
      {
        root_channel: root_channel
      }.to_json(*args)
    end

    private

    def get_users
      @server.getPlayers.first.map do |player_data|
        User.new(*player_data)
      end
    end
  end

  class Channel
    attr_accessor :id, :name, :parent_id, :children, :users

    def initialize(id, name, parent_id, unknown)
      @id = id
      @name = name
      @parent_id = parent_id
      @children = []
      @users = []
    end

    def to_json(*args)
      {
        channel_id: id,
        name: name,
        parent_id: parent_id,
        children: children,
        users: users
      }.to_json(*args)
    end

  end

  USER_FIELDS = [
    :session_id,
    :mute,
    :deaf,
    :suppressed,
    :self_mute,
    :self_deaf,
    :channel_id,
    :id,
    :name,
    :online_time_in_seconds,
    :bytes_per_sec
  ]

  class User < Struct.new(*USER_FIELDS)
    def to_json(*args)
      {}.tap do |hash|
        each_pair do |key, value|
          hash[key] = value
        end
        hash[:talking] = self.bytes_per_sec > 0
      end.to_json(*args)
    end
  end
end
