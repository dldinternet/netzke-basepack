module Netzke
  module Basepack
    class Grid < Netzke::Base
      module Endpoints
        extend ActiveSupport::Concern

        included do
          endpoint :server_read do |data, this|
            attempt_operation(:read, data, this)
          end

          endpoint :server_create do |data, this|
            attempt_operation(:create, data, this)
          end

          endpoint :server_update do |data, this|
            attempt_operation(:update, data, this)
          end

          endpoint :server_delete do |data, this|
            attempt_operation(:destroy, data, this)
          end

          endpoint :server_save_columns do |cols, this|
            state[:columns_order] = cols
          end

          # Returns options for a combobox
          # params receive:
          # +attr+ - column's name
          # +query+ - what's typed-in in the combobox
          # +id+ - selected record id
          endpoint :get_combobox_options do |params, this|
            column = final_columns.detect{ |c| c[:name] == params[:attr] }
            this.data = data_adapter.combo_data(column, params[:query])
          end

          endpoint :move_rows do |params, this|
            data_adapter.move_records(params)
          end

          # Process the submit of multi-editing form ourselves
          # TODO: refactor to let the form handle the validations
          endpoint :multi_edit_window__multi_edit_form__netzke_submit do |params, this|
            ids = ActiveSupport::JSON.decode(params.delete(:ids))
            data = ids.collect{ |id| ActiveSupport::JSON.decode(params[:data]).merge("id" => id) }

            data.map!{|el| el.delete_if{ |k,v| v.is_a?(String) && v.blank? }} # only interested in set values

            res = attempt_operation(:update, data, this)

            errors = []
            res.each do |id, out|
              errors << out[:error] if out[:error]
            end

            if errors.empty?
              on_data_changed
              this.netzke_set_result("ok")
              this.on_submit_success
            end

            this.netzke_feedback(errors)
          end

          # The following two look a bit hackish, but serve to invoke on_data_changed when a form gets successfully
          # submitted
          endpoint :add_window__add_form__netzke_submit do |params, this|
            this.merge!(component_instance(:add_window).
                        component_instance(:add_form).
                        invoke_endpoint(:netzke_submit, params))
            on_data_changed if this.set_form_values.present?
            this.delete(:set_form_values)
          end

          endpoint :edit_window__edit_form__netzke_submit do |params, this|
            this.merge!(component_instance(:edit_window).
                        component_instance(:edit_form).
                        invoke_endpoint(:netzke_submit, params))
            on_data_changed if this.set_form_values.present?
            this.delete(:set_form_values)
          end
        end

        # Operations:
        #   create, read, update, delete
        def attempt_operation(op, data, this)
          if !config["prohibit_#{op}"]
            res = send(op, data)
            this.netzke_set_result res
            res
          else
            this.netzke_feedback I18n.t("netzke.basepack.grid.cannot_#{op}")
          end
        end
      end
    end
  end
end
