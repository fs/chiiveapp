module AuthlogicFacebookConnect
  module Session
    def self.included(klass)
      klass.class_eval do
        extend Config
        include Methods
      end
    end

    module Config
      # What user field should be used for the facebook UID?
      #
      # This is useful if you want to use a single field for multiple types of
      # alternate user IDs, e.g. one that handles both OpenID identifiers and
      # facebook ids.
      #
      # * <tt>Default:</tt> :facebook_uid
      # * <tt>Accepts:</tt> Symbol
      def facebook_uid_field(value = nil)
        rw_config(:facebook_uid_field, value, :facebook_uid)
      end
      alias_method :facebook_uid_field=, :facebook_uid_field

      # def first_name_field(value = nil)
      #   rw_config(:first_name_field, value, :first_name)
      # end
      # alias_method :first_name_field=, :first_name_field
      # 
      # def last_name_field(value = nil)
      #   rw_config(:last_name_field, value, :last_name)
      # end
      # alias_method :last_name_field=, :last_name_field

      def name_field(value = nil)
        rw_config(:name_field, value, :name)
      end
      alias_method :name_field=, :name_field

      def login_field(value = nil)
        rw_config(:login_field, value, :login)
      end
      alias_method :login_field=, :login_field
    end

    module Methods
      def self.included(klass)
        klass.class_eval do
          validate :validate_by_facebook_connect, :if => :authenticating_with_facebook_connect?
        end

        def credentials=(value)
          # TODO: Is there a nicer way to tell Authlogic that we don't have any credentials than this?
          values = [:facebook_connect]
          super
        end
      end

      def validate_by_facebook_connect
        facebook_session = controller.facebook_session

        self.attempted_record =
          klass.find(:first, :conditions => { facebook_uid_field => facebook_session.user.uid })

        unless self.attempted_record
          begin
            # Get the user from facebook and create a local user.
            #
            # We assign it after the call to new in case the attribute is protected.
            new_user = klass.new
            new_user.send(:"#{facebook_uid_field}=", facebook_session.user.uid)
            # new_user.send(:"#{first_name_field}=", facebook_session.user.first_name)
            new_user.send(:"#{last_name_field}=", facebook_session.user.last_name)
            new_user.send(:"#{name_field}=", facebook_session.user.name)
            new_user.send(:"#{login_field}=", "facebooker_#{facebook_session.user.uid}")
            self.attempted_record = new_user
            
            # TODO: Find a better way to save the user record
            # check validation - this will return false since we have not included password or email
            # but it forces a save of the record
            attempted_record.valid?
            
            # removed validation checking - we have no password or email,
            # so the record is not valid and we need to skip
            # errors.add_to_base(
            #   I18n.t('error_messages.facebook_user_creation_failed',
            #        :default => 'There was a problem creating a new user ' +
            #                    'for your Facebook account')) unless attempted_record.valid?
          rescue Facebooker::Session::SessionExpired
            errors.add_to_base(I18n.t('error_messages.facebooker_session_expired', 
              :default => "Your Facebook Connect session has expired, please reconnect."))
          end
        end
      end
      
      def authenticating_with_facebook_connect?
        attempted_record.nil? && errors.empty? && controller.facebook_session
      end

      private
        def facebook_uid_field
          self.class.facebook_uid_field
        end
        # def first_name_field
        #   self.class.first_name_field
        # end
        def last_name_field
          self.class.last_name_field
        end
        def name_field
          self.class.name_field
        end
        def login_field
          self.class.login_field
        end
    end
  end
end
