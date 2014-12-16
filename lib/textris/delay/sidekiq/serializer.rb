module Textris
  module Delay
    module Sidekiq
      module Serializer
        ACTIVERECORD_POINTER       = 'Textris::ActiveRecordPointer'
        ACTIVERECORD_ARRAY_POINTER = 'Textris::ActiveRecordArrayPointer'

        class << self
          def serialize(objects)
            objects.collect do |object|
              serialize_active_record_object(object) ||
                serialize_active_record_array(object) ||
                serialize_active_record_relation(object) ||
                object
            end
          rescue NameError
            objects
          end

          def deserialize(objects)
            objects.collect do |object|
              deserialize_active_record_object(object) ||
                object
            end
          end

          private

          def serialize_active_record_object(object)
            if object.class < ActiveRecord::Base && object.id.present?
              [ACTIVERECORD_POINTER, object.class.to_s, object.id]
            end
          end

          def serialize_active_record_relation(array)
            if array.class < ActiveRecord::Relation
              [ACTIVERECORD_ARRAY_POINTER, array.model.to_s, array.map(&:id)]
            end
          end

          def serialize_active_record_array(array)
            if array.is_a?(Array) &&
                (model = get_active_record_common_model(array))
              [ACTIVERECORD_ARRAY_POINTER, model, array.map(&:id)]
            end
          end

          def deserialize_active_record_object(object)
            if object.is_a?(Array) &&
                object.try(:length) == 3 &&
                [ACTIVERECORD_POINTER,
                 ACTIVERECORD_ARRAY_POINTER].include?(object[0])
              object[1].constantize.find(object[2])
            end
          end

          def get_active_record_common_model(items)
            items = items.collect do |item|
              if item.class < ActiveRecord::Base
                item.class.to_s
              end
            end.uniq

            if items.size == 1
              items.first
            end
          end
        end
      end
    end
  end
end
