<template>  
  <div class="founding-sponsor__grid">
    <a class="founding-sponsor" v-for="sponsor in sponsors" target="_blank" rel="noopener" :href="sponsor.url">
      <img :src="sponsor.logo" :alt="sponsor.name + ' logo'" :width="sponsor.width" :height="sponsor.height" />
    </a>
  </div>
</template>


<script>
export default {
  props: ['sponsors']
}
</script>

<style>
.founding-sponsor__grid {
  padding: 2rem;
  margin: 0 -4rem;
  display: grid;
  gap: 2rem;
  justify-content: center;
  grid-template-columns: repeat(auto-fit, 480px);
}
.founding-sponsor {
  display: flex;
  flex-direction: column;
  gap: 1rem;
  padding: 1rem;
  margin: 0;
  transition: opacity 200ms ease-in-out;
}
.founding-sponsor:hover {
  opacity: 0.75;
}

.founding-sponsor h3 {
  padding: 0;
  margin: 0;
}
.founding-sponsor img {
  border-radius: 4px;
  margin: 0;
  flex-grow: 1;
}
</style>