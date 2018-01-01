module FineMailHelper
  def hr
    <<-EOS.html_safe
      <div style="
        border-bottom: 1px solid #E5E5E5;
        margin-top: 10px;
        margin-bottom:10px;
        "></div>
    EOS
  end

  def fine_mail_email_issue_attributes(issue, user)
    items = []
    %w(author status priority assigned_to category fixed_version).each do |attribute|
      unless issue.disabled_core_fields.include?(attribute + "_id")
        items << { key: l("field_#{attribute}"), value: issue.send(attribute) }
      end
    end
    issue.visible_custom_field_values(user).each do |value|
      items << { key: value.custom_field.name, value: show_value(value, false) }
    end
    items
  end

  def fine_mail_details_diffs(details)
    detail_diffs = []
    values_by_field = {}
    details.each do |detail|
      if detail.property == 'cf'
        field = detail.custom_field
        if field && field.multiple?
          values_by_field[field] ||= {:added => [], :deleted => []}
          if detail.old_value
            values_by_field[field][:deleted] << detail.old_value
          end
          if detail.value
            values_by_field[field][:added] << detail.value
          end
          next
        end
      end

      detail_diffs << fine_mail_detail_diff(detail)
    end

    if values_by_field.present?
      multiple_values_detail = Struct.new(:property, :prop_key, :custom_field, :old_value, :value)
      values_by_field.each do |field, changes|
        if changes[:added].any?
          detail = multiple_values_detail.new('cf', field.id.to_s, field)
          detail.value = changes[:added]
          detail_diffs << fine_mail_detail_diff(detail)
        end
        if changes[:deleted].any?
          detail = multiple_values_detail.new('cf', field.id.to_s, field)
          detail.old_value = changes[:deleted]
          detail_diffs << fine_mail_detail_diff(detail)
        end
      end
    end

    detail_diffs
  end

  private

  def fine_mail_detail_diff(detail)
    multiple = false
    show_diff = false

    case detail.property
    when 'attr'
      field = detail.prop_key.to_s.gsub(/\_id$/, "")
      label = l(("field_" + field).to_sym)
      case detail.prop_key
      when 'due_date', 'start_date'
        value = format_date(detail.value.to_date) if detail.value
        old_value = format_date(detail.old_value.to_date) if detail.old_value

      when 'project_id', 'status_id', 'tracker_id', 'assigned_to_id',
            'priority_id', 'category_id', 'fixed_version_id'
        value = find_name_by_reflection(field, detail.value)
        old_value = find_name_by_reflection(field, detail.old_value)

      when 'estimated_hours'
        value = l_hours_short(detail.value.to_f) unless detail.value.blank?
        old_value = l_hours_short(detail.old_value.to_f) unless detail.old_value.blank?

      when 'parent_id'
        label = l(:field_parent_issue)
        value = "##{detail.value}" unless detail.value.blank?
        old_value = "##{detail.old_value}" unless detail.old_value.blank?

      when 'is_private'
        value = l(detail.value == "0" ? :general_text_No : :general_text_Yes) unless detail.value.blank?
        old_value = l(detail.old_value == "0" ? :general_text_No : :general_text_Yes) unless detail.old_value.blank?

      when 'description'
        show_diff = true
      end
    when 'cf'
      custom_field = detail.custom_field
      if custom_field
        label = custom_field.name
        if custom_field.format.class.change_as_diff
          show_diff = true
        else
          multiple = custom_field.multiple?
          value = format_value(detail.value, custom_field) if detail.value
          old_value = format_value(detail.old_value, custom_field) if detail.old_value
        end
      end
    when 'attachment'
      label = l(:label_attachment)
      if detail.value.present?
        value = detail.journal.journalized.attachments.detect {|a| a.id == detail.prop_key.to_i}
      end
    when 'relation'
      if detail.value && !detail.old_value
        rel_issue = Issue.visible.find_by_id(detail.value)
        value = rel_issue.nil? ? "#{l(:label_issue)} ##{detail.value}" : rel_issue
      elsif detail.old_value && !detail.value
        rel_issue = Issue.visible.find_by_id(detail.old_value)
        old_value = rel_issue.nil? ? "#{l(:label_issue)} ##{detail.old_value}" : rel_issue
      end
      relation_type = IssueRelation::TYPES[detail.prop_key]
      label = l(relation_type[:name]) if relation_type
    end

    label ||= detail.prop_key
    value ||= detail.value
    old_value ||= detail.old_value

    change =
      if show_diff
        :updated
      elsif value.present?
        case detail.property
        when 'attr', 'cf'
          if old_value.present?
            :changed
          elsif multiple
            :added
          else
            :set_to
          end
        when 'attachment', 'relation'
          :added
        end
      else
        :deleted
      end

    OpenStruct.new({
      detail: detail, change: change,
      label: label, value: value, old_value: old_value
    })
  end
end

