<template>  
  <div class="grid">
    <a class="news-post grid__tile" v-for="tile in tiles" target="_blank" rel="noopener" :href="toUrl(tile.id)">
      <h3 v-text="tile.title"></h3>
      <img :src="tile.src" alt="Screenshot" width="320" height="180" />
    </a>
  </div>
</template>


<script>
export default {
  data: () => ({
    tiles: [
      { kind: "official", title: "🌱 Hello, world!", id: "01-hello-world", src: "/images/guide/hello-world.jpg" },
      { kind: "official", title: "🔗 Pages and routes", id: "02-pages-and-routes", src: "/images/guide/pages-and-routes.gif" },
      { kind: "official", title: "🔢 User input", id: "03-user-input", src: "/images/guide/user-input.gif" },
      { kind: "official", title: "🗣 REST APIs", id: "04-rest-apis", src: "/images/guide/rest-apis.gif" },
      { kind: "official", title: "🔐 User auth", id: "05-user-auth", src: "/images/guide/user-auth.gif" },
      { kind: "official", title: "📊 Query Parameters", id: "06-query-parameters", src: "/images/guide/query-parameters.gif" },
      { kind: "official", title: "🧱 Working with JS", id: "07-working-with-js", src: "/images/examples/working-with-js.gif" },
      { kind: "official", title: "🪆 Nested Layouts", id: "08-nested-layouts", src: "/images/examples/nested-layouts.gif" },
      { kind: "official", title: "🧩 TypeScript Interop", id: "10-typescript-interop", src: "/images/examples/typescript.gif" },
      { kind: "official", title: "🚨 Error Reporting", id: "11-error-reporting", src: "/images/examples/sentry.gif" },
      { kind: "official", title: "🎨 Using Elm UI", id: "12-elm-ui", src: "/images/examples/elm-ui.jpg" },
      { kind: "official", title: "👩‍🎨 Using Elm CSS", id: "13-elm-css", src: "/images/examples/elm-css.jpg" },
      { kind: "official", title: "💁 SCSS & Assets", id: "14-scss-and-assets", src: "/images/examples/scss.jpg" },
      { kind: "official", title: "🤷 Custom 404 Pages", id: "15-custom-404-pages", src: "/images/examples/404.jpg" },
      { kind: "official", title: "#️⃣ Hash-based Routing", id: "16-hash-based-routing", src: "/images/guide/pages-and-routes.gif" },
    ]
  }),
  methods: {
    toUrl: (id) => {
      return `https://github.com/elm-land/elm-land/tree/main/examples/${id}`
    }
  }
}
</script>

<style>
.grid {
  display: grid;
  gap: 2rem;
  justify-content: center;
  grid-template-columns: repeat(auto-fit, minmax(240px, 1fr));
}
.grid__tile {
  display: flex;
  flex-direction: column;
  gap: 1rem;
  padding: 1rem;
  margin: 0;
}

.grid__tile h3 {
  padding: 0;
  margin: 0;
}
.grid__tile img {
  border-radius: 4px;
  margin: 0;
  flex-grow: 1;
}
</style>