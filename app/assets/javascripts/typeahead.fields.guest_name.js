var guest_names = new Bloodhound({
  datumTokenizer: Bloodhound.tokenizers.whitespace,
  queryTokenizer: Bloodhound.tokenizers.whitespace,
  prefetch: '/guest_names'
});

$('#guest_name').typeahead(
  {
    hint: false,
    highlight: true,
  },
  {
    name: 'guest_names',
    source: guest_names,
  }
);
