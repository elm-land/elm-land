<template>  
  <a class="news-post" :href="url" :aria-label="title">
    <div class="news-post__header">
      <span class="news-post__emoji" v-text="emoji"></span>
      <span class="news-post__title" v-text="title"></span>
    </div>
    <div class="news-post__body">
      <span class="news-post__date" v-text="date"></span>
      <span class="news-post__description" v-text="description"></span>
    </div>
  </a>
</template>


<script>
export default {
  props: {
    emoji: String,
    title: String,
    url: String,
    description: String,
    date: String,
  }
}
</script>