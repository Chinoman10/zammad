class App.Checklist extends App.Model
  @configure 'Checklist', 'name', 'sorted_item_ids', 'active', 'updated_at'
  @extend Spine.Model.Ajax
  @url: @apiPath + '/checklists'

  @configure_attributes = [
    { name: 'name', display: __('Name'),    tag: 'input', type: 'text', maxlength: 255 },
    { name: 'sorted_item_ids', display: __('Items'),   tag: 'checklist_item',  type: 'text' },
    { name: 'created_at', display: __('Created at'), tag: 'datetime', readonly: 1 },
    { name: 'updated_at', display: __('Updated at'), tag: 'datetime', readonly: 1 },
  ]

  sorted_items: =>
    App.ChecklistItem.findAll(@sorted_item_ids)

  open_items: =>
    @sorted_items().filter (item) ->
      if item.ticket_id
        ticket = App.Ticket.find(item.ticket_id)
        if ticket
          if ticket.userGroupAccess('read')
            ticketState    = App.TicketState.fullLocal(ticket.state_id)
            ticketState.state_type.name isnt 'closed' && ticketState.state_type.name isnt 'merged'
          else
            false # no access
        else
          false # no access
      else
        !item.checked

  @completedForTicketId: (ticket_id, callback) =>
    App.Ajax.request(
      id: 'checklist_completed'
      type: 'GET'
      url:  "#{@apiPath}/tickets/#{ticket_id}/checklist/completed"
      success: (data, status, xhr) ->
        callback(data)
    )

  @calculateState: (ticket) ->
    return if !ticket.checklist_incomplete

    {
      all: ticket.checklist_total
      open: ticket.checklist_incomplete

    }

  @calculateReferences: (ticket) ->
    return [] if !ticket.referencing_checklist_ids

    checklists = App.Checklist
      .findAll(ticket.referencing_checklist_ids)
      .filter (elem) -> !elem.ticket_inaccessible

    App.Ticket.findAll checklists.map (elem) -> elem.ticket_id
