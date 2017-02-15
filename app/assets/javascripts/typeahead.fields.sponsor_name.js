var sponsor_names = new Bloodhound({
  datumTokenizer: Bloodhound.tokenizers.whitespace,
  queryTokenizer: Bloodhound.tokenizers.whitespace,
  prefetch: '/sponsor_names'
});

$('#sponsor_name').typeahead(
  {
    hint: false,
    highlight: true,
  },
  {
    name: 'sponsor_names',
    source: sponsor_names,
  }
);
