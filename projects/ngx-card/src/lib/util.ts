export const uniqueId = (() => {
  let counter = 0;
  return (prefix = 'uid'): string => `card_${prefix}_${++counter}`;
})();
