# CONTAINS TWO MONKEY PATCHES !!!!!

# obtained from https://gist.github.com/1523940
# add Squeel to Gemfile, see https://github.com/ernie/squeel
#
#     gem "squeel", "~> 0.9.3"
#
# put this in Rails.root/config/initializers/cancan.rb
# then you can write
#
#    can :manage, User, :permissions.outer => {:type.matches => 'Manage%'}}
#
# This should offer all the old MetaWhere capabilities,
# and extra, also allows outer joins
# you might also be interested in https://gist.github.com/1012332

module CanCan
  
  module ModelAdapters
    class ActiveRecordAdapter < AbstractAdapter

      def self.override_condition_matching?(subject, name, value)
        name.kind_of?(Squeel::Nodes::Predicate) if defined? Squeel
      end
      
      def self.matches_condition?(subject, name, value)
        subject_value = subject.send(name.expr)
        method_name = name.method_name.to_s
        if method_name.ends_with? "_any"
          value.any? { |v| squeel_match? subject_value, method_name.sub("_any", ""), v }
        elsif method_name.ends_with? "_all"
          value.all? { |v| squeel_match? subject_value, method_name.sub("_all", ""), v }
        else
          squeel_match? subject_value, name.method_name, value
        end
      end
      
      def self.squeel_match?(subject_value, method, value)
        case method.to_sym
        when :eq      then subject_value == value
        when :not_eq  then subject_value != value
        when :in      then value.include?(subject_value)
        when :not_in  then !value.include?(subject_value)
        when :lt      then subject_value < value
        when :lteq    then subject_value <= value
        when :gt      then subject_value > value
        when :gteq    then subject_value >= value
        when :matches then subject_value =~ Regexp.new("^" + Regexp.escape(value).gsub("%", ".*") + "$", true)
        when :does_not_match then !squeel_match?(subject_value, :matches, value)
        else raise NotImplemented, "The #{method} Squeel condition is not supported."
        end
      end
      
      def tableized_conditions(conditions, model_class = @model_class)
        return conditions unless conditions.kind_of? Hash
        conditions.inject({}) do |result_hash, (name, value)|
          name_sym = case name
          when Symbol                   then name
          when Squeel::Nodes::Join      then name._name
          when Squeel::Nodes::Predicate then name.expr
          else raise name
          end
          if value.kind_of? Hash
            reflection = model_class.reflect_on_association(name_sym)
            association_class = reflection.class_name.constantize
            name_sym = reflection.table_name.to_sym
            value = tableized_conditions(value, association_class)
          end
          result_hash[name_sym] = value
          result_hash
        end
      end
      
      private
      
      # override to fix overwrites
      # do not write existing hashes using empty hashes
      def merge_joins(base, add)
        add.each do |name, nested|
          if base[name].is_a?(Hash) && nested.present?
            merge_joins(base[name], nested)
          elsif !base[name].is_a?(Hash) || nested.present?
            base[name] = nested
          end
        end
      end

    end
  end
  
  class Rule
    # allow Squeel
    def matches_conditions_hash?(subject, conditions = @conditions)
      if conditions.empty?
        true
      else
        if model_adapter(subject).override_conditions_hash_matching? subject, conditions
          model_adapter(subject).matches_conditions_hash? subject, conditions
        else
          conditions.all? do |name, value|
            if model_adapter(subject).override_condition_matching? subject, name, value
              model_adapter(subject).matches_condition? subject, name, value
            else
              method_name = case name
              when Symbol                   then name
              when Squeel::Nodes::Join      then name._name
              when Squeel::Nodes::Predicate then name.expr
              else raise name
              end
              attribute = subject.send(method_name)
              if value.kind_of?(Hash)
                if attribute.kind_of? Array
                  attribute.any? { |element| matches_conditions_hash? element, value }
                else
                  !attribute.nil? && matches_conditions_hash?(attribute, value)
                end
              elsif value.kind_of?(Array) || value.kind_of?(Range)
                value.include? attribute
              else
                attribute == value
              end
            end
          end
        end
      end
    end
  end
end


# obtained from https://gist.github.com/1012332
# monkey-patch https://github.com/ryanb/cancan/issues/327
# put in Rails.root/config/initializers/cancan.rb
# module CanCan
#   module ModelAdapters
#     class ActiveRecordAdapter
#       private
#       
#       # fix nested imbrication
#       def merge_conditions(sql, conditions_hash, behavior)
#         if conditions_hash.blank?
#           behavior ? true_sql : false_sql
#         else
#           conditions = sanitize_sql(conditions_hash)
#           case sql
#           when true_sql
#             behavior ? true_sql : "not (#{conditions})"
#           when false_sql
#             behavior ? conditions : false_sql
#           else
#             behavior ? "(#{conditions}) OR #{sql}" : "(not (#{conditions}) AND #{sql})" # fix here
#           end
#         end
#       end
# 
#       # fix MetaWhere conditions
#       def sanitize_sql(conditions)
#         conditions.is_a?(Hash) ? sanitize_hash(conditions) : @model_class.send(:sanitize_sql, conditions)
#       end
#       
#       def sanitize_hash(conditions, parent_table = nil)
#         sql_fragments = []
#         for k, v in conditions # going down to last hash
#           if v.is_a?(Hash)
#             sql_fragments << sanitize_hash(v, k)
#           elsif k.is_a?(MetaWhere::Column)
#             sql_fragments << sanitize_meta_where(k, v, parent_table)
#           end
#         end
#         clean_meta_where_subtree(conditions) # clean separate because ruby 1.9.2 segfault ...
#         if conditions.present?
#           sql_fragments << @model_class.send(:sanitize_sql, 
#             parent_table.nil? ? conditions : {parent_table => conditions})
#         end
#         sql_fragments.reject(&:blank?).uniq.join(' AND ')
#       end
#             
#       def sanitize_meta_where(k ,v, parent_table = nil)
#         condition = k % v # MW::Column % val -> MW::Condition
#         column_name = condition.column.to_s
#         if column_name.include?('.')
#           table_name, column_name = column_name.split('.', 2)
#           table = Arel::Table.new(table_name, :engine => @model_class.arel_engine)
#         elsif parent_table.present?
#           table = Arel::Table.new(parent_table, :engine => @model_class.arel_engine)
#         else
#           table = @model_class.arel_table
#         end
# 
#         unless attribute = table[column_name]
#           raise ::ActiveRecord::StatementInvalid, "No attribute named `#{column_name}` exists for table `#{table.name}`"
#         end
# 
#         if condition.value.nil?
#           conditions = [attribute.send(condition.method, nil).to_sql]
#         else
#           placeholder = Arel::Nodes::SqlLiteral.new('?')
#           conditions = [attribute.send(condition.method, placeholder).to_sql, condition.value]	
#         end
#         
#         @model_class.send(:sanitize_sql, conditions)
#       end
#       
#       # Removes all subtrees that contain a meta where key.
#       # 
#       # Example:
#       # 
#       #   { :a => 1
#       #     :b => {:c => 1},
#       #     :d => {#mw => 1},
#       #     :e => {#mw => 1, :f => 1},
#       #     #mw => {:g => 1} }
#       #     
#       #   to:
#       # 
#       #   { :a => 1
#       #     :b => {:c => 1},
#       #     :e => {:f => 1} }
#       #
#       def clean_meta_where_subtree(conditions)
#         for k, v in conditions
#           if k.is_a?(MetaWhere::Column)
#             conditions.delete(k)
#           elsif v.is_a?(Hash)
#             clean_meta_where_subtree(v)
#             conditions.delete(k) if v.blank?
#           end
#         end
#       end
# 
#     end
#   end
# end
