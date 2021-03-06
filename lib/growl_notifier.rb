require 'osx/cocoa'

module Growl
  class Logger
    attr_accessor :level
    
    LEVELS = [:debug,:info,:warn,:error,:fatal]
    
    def initialize(app_name = "#{__FILE__} logger", default_notifications = nil, application_icon = nil)
      # Check to see if Growl is available?
      @log = Notifier.sharedInstance
      @log.register(app_name,LEVELS.collect{|w| w.to_s.capitalize},default_notifications, application_icon)
      @level = :info
    end
    
    def level=(level)
      @level = parse_level(level)
    end
    
    def fatal(message,title=nil); log(:fatal,message,title); end
    def error(message,title=nil); log(:error,message,title); end
    def warn(message,title=nil);  log(:warn,message,title);  end
    def info(message,title=nil);  log(:info,message,title);  end
    def debug(message,title=nil); log(:debug,message,title); end

    def log(level,message,title=nil)
      level = parse_level(level)
      if LEVELS.index(@level) <= LEVELS.index(level)
        title ||= level.to_s.capitalize
        @log.notify(level.to_s.capitalize, title, message,:priority => LEVELS.index(level) - 2)
      end
    end
    
    private
    def parse_level(level)
      case level
      when Symbol,String
        (LEVELS.include? level.to_sym) ? level.to_sym : :info
      when 0..4
        LEVELS[level]
      else
        raise ArgumentError, "Please use Symbols (see Growl::Logger::LEVELS) or Logger Constants (eg. Logger::WARN)"
      end
    end
  end
  
  class Notifier < OSX::NSObject
    GROWL_IS_READY = "Lend Me Some Sugar; I Am Your Neighbor!"
    GROWL_NOTIFICATION_CLICKED = "GrowlClicked!"
    GROWL_NOTIFICATION_TIMED_OUT = "GrowlTimedOut!"
    GROWL_KEY_CLICKED_CONTEXT = "ClickedContext"
    
    PRIORITIES = {
      :emergency =>  2,
      :high      =>  1,
      :normal    =>  0,
      :moderate  => -1,
      :very_low  => -2,
    }
    
    class << self
      # Returns the singleton instance of Growl::Notifier with which you register and send your Growl notifications.
      def sharedInstance
        @sharedInstance ||= alloc.init
      end
    end
    
    attr_reader :application_name, :application_icon, :notifications, :default_notifications
    attr_accessor :delegate
    
    # Set to +true+ if you want to receive delegate callback messages,
    # <tt>growlNotifierClicked_context</tt> & <tt>growlNotifierTimedOut_context</tt>,
    # without the need to specify a <tt>:click_context</tt>.
    #
    # The default is +false+, which means your application won't receive any delegate
    # callback messages if the <tt>:click_context</tt> is omitted.
    attr_accessor :always_callback
    
    # Registers the applications metadata and the notifications, that your application might send, to Growl.
    # The +default_notifications+ are notifications that will be enabled by default, the regular +notifications+ are
    # optional and should be enabled by the user in the Growl system preferences.
    #
    # Register the applications name and the notifications that will be used.
    # * +default_notifications+ defaults to the regular +notifications+.
    # * +application_icon+ defaults to OSX::NSApplication.sharedApplication.applicationIconImage.
    #
    #   Growl::Notifier.sharedInstance.register 'FoodApp', ['YourHamburgerIsReady', 'OhSomeoneElseAteIt']
    #
    # Register the applications name, the notifications plus the default notifications that will be used and the icon that's to be used in the Growl notifications.
    #
    #   Growl::Notifier.sharedInstance.register 'FoodApp', ['YourHamburgerIsReady', 'OhSomeoneElseAteIt'], ['DefaultNotification'], 'GreasyHamburger.png')
    def register(application_name, notifications, default_notifications = nil, application_icon = nil)
      @application_name      = application_name
      @application_icon      = OSX::NSImage.alloc.initWithContentsOfFile(application_icon) || OSX::NSApplication.sharedApplication.applicationIconImage
      @notifications         = notifications
      @default_notifications = default_notifications || notifications
      @callbacks = {}
      send_registration!
    end
    
    # Sends a Growl notification.
    #
    # * +notification_name+ : the name of one of the notifcations that your apllication registered with Growl. See register for more info.
    # * +title+ : the title that should be used in the Growl notification.
    # * +description+ : the body of the Grow notification.
    # * +options+ : specifies a few optional options:
    #   * <tt>:sticky</tt> : indicates if the Grow notification should "stick" to the screen. Defaults to +false+.
    #   * <tt>:priority</tt> : sets the priority level of the Growl notification. Defaults to 0.
    #   * <tt>:click_context</tt> : a string describing the context of the notification. This is send back to the delegate so you can check what kind of notification it was. If omitted, no delegate messages will be send. You can disable this behaviour by setting always_callback to +true+.
    #   * <tt>:icon</tt> : specifies the icon to be used in the Growl notification. Defaults to the registered +application_icon+, see register for more info.
    #
    # Simple example:
    #
    #   name = 'YourHamburgerIsReady'
    #   title = 'Your hamburger is ready for consumption!'
    #   description = 'Please pick it up at isle 4.'
    #   
    #   Growl::Notifier.sharedInstance.notify(name, title, description)
    #
    # Example with optional options:
    #
    #   Growl::Notifier.sharedInstance.notify(name, title, description, :sticky => true, :priority => 1, :icon => OSX::NSImage.imageNamed('SuperBigHamburger'))
    #
    # When you pass notify a block, that block will be used as the callback handler if the Growl notification was clicked. Eg:
    #
    #   Growl::Notifier.sharedInstance.notify(name, title, description, :sticky => true) do
    #     user_clicked_notification_so_do_something!
    #   end
    def notify(notification_name, title, description, options = {}, &callback)
      dict = {
        :ApplicationName => @application_name,
        :ApplicationPID => pid,
        :NotificationName => notification_name,
        :NotificationTitle => title,
        :NotificationDescription => description,
        :NotificationPriority => PRIORITIES[options[:priority]] || options[:priority] || 0
      }
      dict[:NotificationIcon] = options[:icon].TIFFRepresentation if options[:icon]
      dict[:NotificationSticky] = 1 if options[:sticky]
      
      context = {}
      context[:user_click_context] = options[:click_context] if options[:click_context]
      if block_given?
        @callbacks[callback.object_id] = callback
        context[:callback_object_id] = callback.object_id.to_s
      end
      dict[:NotificationClickContext] = context if always_callback || !context.empty?
      
      notification_center.postNotificationName_object_userInfo_deliverImmediately(:GrowlNotification, nil, dict, true)
    end
    
    def onReady(notification)
      send_registration!
    end
    
    def onClicked(notification)
      user_context = nil
      if context = notification.userInfo[GROWL_KEY_CLICKED_CONTEXT]
        user_context = context[:user_click_context]
        if callback_object_id = context[:callback_object_id]
          @callbacks.delete(callback_object_id.to_i).call
        end
      end
      
      @delegate.growlNotifierClicked_context(self, user_context) if @delegate && @delegate.respond_to?(:growlNotifierClicked_context)
    end
    
    def onTimeout(notification)
      user_context = nil
      if context = notification.userInfo[GROWL_KEY_CLICKED_CONTEXT]
        @callbacks.delete(context[:callback_object_id].to_i) if context[:callback_object_id]
        user_context = context[:user_click_context]
      end
      
      @delegate.growlNotifierTimedOut_context(self, user_context) if @delegate && @delegate.respond_to?(:growlNotifierTimedOut_context)
    end
    
    private
    
    def pid
      OSX::NSProcessInfo.processInfo.processIdentifier.to_i
    end
    
    def notification_center
      OSX::NSDistributedNotificationCenter.defaultCenter
    end
    
    def send_registration!
      add_observer 'onReady:', GROWL_IS_READY, false
      add_observer 'onClicked:', GROWL_NOTIFICATION_CLICKED, true
      add_observer 'onTimeout:', GROWL_NOTIFICATION_TIMED_OUT, true
      
      dict = {
        :ApplicationName => @application_name,
        :ApplicationIcon => application_icon.TIFFRepresentation,
        :AllNotifications => @notifications,
        :DefaultNotifications => @default_notifications
      }
      
      notification_center.objc_send(
        :postNotificationName, :GrowlApplicationRegistrationNotification,
                      :object, nil,
                    :userInfo, dict,
          :deliverImmediately, true
      )
    end
    
    def add_observer(selector, name, prepend_name_and_pid)
      name = "#{@application_name}-#{pid}-#{name}" if prepend_name_and_pid
      notification_center.addObserver_selector_name_object self, selector, name, nil
    end
  end
end