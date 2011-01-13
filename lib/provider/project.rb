module TicketMaster::Provider
  module Bugzilla
    # Project class for ticketmaster-bugzilla
    # 
    class Project < TicketMaster::Provider::Base::Project
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
                    :description => object.name}
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

      def self.find_by_attributes(*options)
        hash = options.first
        PRODUCT_API.list.select do |product|
          hash.inject(true) do |memo, kv|
            key, value = kv
            begin
              memo &= product.send(key) == value
            rescue
              memo = false
            end
            self.new memo
          end
        end
      end

    end
  end
end
