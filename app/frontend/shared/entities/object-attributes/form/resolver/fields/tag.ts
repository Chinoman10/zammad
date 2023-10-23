// Copyright (C) 2012-2023 Zammad Foundation, https://zammad-foundation.org/

import { useApplicationStore } from '#shared/stores/application.ts'
import type { FieldResolverModule } from '#shared/entities/object-attributes/types/resolver.ts'
import FieldResolver from '../FieldResolver.ts'

export class FieldResolverTag extends FieldResolver {
  fieldType = 'tags'

  // eslint-disable-next-line class-methods-use-this
  public fieldTypeAttributes() {
    const application = useApplicationStore()

    return {
      props: {
        canCreate: Boolean(application.config.tag_new),
      },
    }
  }
}

export default <FieldResolverModule>{
  type: 'tag',
  resolver: FieldResolverTag,
}
