// Real, freely licensed workwear/craft photography (Pexels license: free for
// commercial use, no attribution required). Referenced by numeric photo ID.
export function pexelsUrl(id: number, width: number, height: number) {
  return `https://images.pexels.com/photos/${id}/pexels-photo-${id}.jpeg?auto=compress&cs=tinysrgb&w=${width}&h=${height}&fit=crop`;
}
