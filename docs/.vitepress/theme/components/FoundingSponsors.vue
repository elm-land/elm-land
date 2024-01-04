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
    grid-template-columns: repeat(auto-fit, min(320px, 80vw));
}

.founding-sponsor {
    display: flex;
    flex: 1 1 auto;
    padding: 0 2rem;
    margin: 0;
    transition: opacity .2s ease-in-out;
    background: white;
    border-radius: 16px;
    overflow: hidden;
    min-height: 120px;
    align-items: center;
}

.founding-sponsor:hover {
    opacity: .75
}

.founding-sponsor h3 {
    padding: 0;
    margin: 0
}

.founding-sponsor img {
    margin: 0;
    max-width: 100%;
}
</style>
