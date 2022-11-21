<template>  
  <div class="browser">
    <div class="browser__header">
      <div class="browser__buttons">
        <span class="browser__button browser__button--red"></span>
        <span class="browser__button browser__button--yellow"></span>
        <span class="browser__button browser__button--green"></span>
      </div>
      <div class="browser__urlbar"></div>
    </div>
    <img class="browser__image" :src="src" :alt="alt" />
  </div>
</template>


<script>
export default {
  props: {
    src: String,
    alt: String
  }
}
</script>