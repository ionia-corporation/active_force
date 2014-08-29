module ActiveForce
  module Persistence
    extend ActiveSupport::Concern

    module ClassMethods
      def create args
        new(args).save
      end

      def create! args
        new(args).save!
      end

      def build sf_table_description
        return unless sf_table_description
        sobject = new
        mappings.each do |attr, sf_field|
          sobject[attr] = sf_table_description[sf_field]
        end
        sobject.changed_attributes.clear
        sobject
      end
    end

    def persisted?
      id?
    end

    def update_attributes! attributes = {}
      assign_attributes attributes
      return false unless valid?
      sfdc_client.update! table_name, attributes_for_sfdb_update
      changed_attributes.clear
      self
    end

    def update_attributes attributes = {}
      run_callbacks :update do
        update_attributes! attributes
      end
    rescue Faraday::Error::ClientError => error
      logger_output __method__
    end

    alias_method :update, :update_attributes

    def create!
      return false unless valid?
      self.id = sfdc_client.create! table_name, attributes_for_sfdb_create
      changed_attributes.clear
      self
    end

    def create
      run_callbacks :create do
        create!
      end
    rescue Faraday::Error::ClientError => error
      logger_output __method__
    end

    def save
      run_callbacks :save do
        if persisted?
          update
        else
          create
        end
      end
    end

    def save!
      save
    rescue Faraday::Error::ClientError => error
      logger_output __method__
    end

    def reload
      association_cache.clear
      reloaded = self.class.find(id)
      self.attributes = reloaded.attributes
      self
    end

    private

    def association_cache
      @association_cache ||= {}
    end

    def attributes_for_sfdb_create
      attrs = mappings.map do |attr, sf_field|
        value = read_attribute(attr)
        [sf_field, value] if value
      end
      Hash.new(attrs.compact)
    end


    def attributes_for_sfdb_update
      attrs = changed_mappings.map do |attr, sf_field|
        [sf_field, read_attribute(attr)]
      end
      Hash.new(attrs).merge('Id' => id)
    end
  end
end
