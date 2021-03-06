module TaskMapper::Provider
  module Bugzilla
    # Project class for taskmapper-bugzilla
    # 
    class Project < TaskMapper::Provider::Base::Project
      # declare needed overloaded methods here
      PRODUCT_API = Rubyzilla::Product
      
      # TODO: Add created_at and updated_at 
      def initialize(*object)
        if object.first
          object = object.first
          unless object.is_a? Hash
            @system_data = {:client => object}
            hash = {:id => object.id,
                    :name => object.name,
                    :description => object.name, 
                    :created_at => nil, 
                    :updated_at => nil}
          else
            hash = object
          end
          super(hash)
        end
      end
      
      # copy from this.copy(that) copies that into this
      def copy(project)
        project.tickets.each do |ticket|
          copy_ticket = self.ticket!(:title => ticket.title, :description => ticket.description)
          ticket.comments.each do |comment|
            copy_ticket.comment!(:body => comment.body)
            sleep 1
          end
        end
      end

      def self.find_by_id(id)
        self.new PRODUCT_API.new id
      end

      def self.find_by_attributes(attributes = {})
        search_by_attribute(self.find_all, attributes)
      end

      def self.find_all(*options)
        PRODUCT_API.list.collect { |product| self.new product }
      end

      def tickets(*options)
        TaskMapper::Provider::Bugzilla::Ticket.find(self.id, options)
      end

      def ticket(*options)
        TaskMapper::Provider::Bugzilla::Ticket.find_by_id(options.first)
      end

      def ticket!(*options)
        TaskMapper::Provider::Bugzilla::Ticket.create(self.id,*options)
      end

    end
  end
end
