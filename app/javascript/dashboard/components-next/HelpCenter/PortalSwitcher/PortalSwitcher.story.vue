<script setup>
import PortalSwitcher from './PortalSwitcher.vue';

const portals = [
  {
    id: 1,
    name: 'Kirvano Help Center',
    articles: 67,
    domain: 'kirvano.help',
    slug: 'help-center',
  },
  {
    id: 2,
    name: 'Kirvano Handbook',
    articles: 42,
    domain: 'kirvano.help',
    slug: 'handbook',
  },
  {
    id: 3,
    name: 'Developer Documentation',
    articles: 89,
    domain: 'dev.kirvano.com',
    slug: 'docs',
  },
];
</script>

<template>
  <Story
    title="Components/HelpCenter/PortalSwitcher"
    :layout="{ type: 'grid', width: '510px' }"
  >
    <Variant title="Portal Switcher">
      <div class="h-[500px] p-4 bg-slate-100 dark:bg-slate-900">
        <PortalSwitcher
          :portals="portals"
          header="Choose a Portal"
          description="Select from available help center portals"
        />
      </div>
    </Variant>
  </Story>
</template>
