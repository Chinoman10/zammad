# Copyright (C) 2012-2024 Zammad Foundation, https://zammad-foundation.org/

require 'rails_helper'
require 'system/examples/pagination_examples'

RSpec.describe 'Manage > Macro', type: :system do
  context 'when ajax pagination' do
    include_examples 'pagination', model: :macro, klass: Macro, path: 'manage/macros'
  end
end
