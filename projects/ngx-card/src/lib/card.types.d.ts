declare module 'card' {
  interface CardJsOptions {
    form: HTMLElement;
    container?: string | HTMLElement;
    width?: number;
    formSelectors: {
      numberInput: string;
      expiryInput: string;
      cvcInput: string;
      nameInput: string;
    };
    formatting?: boolean;
    messages?: {
      validDate?: string;
      monthYear?: string;
    };
    placeholders?: {
      number?: string;
      name?: string;
      expiry?: string;
      cvc?: string;
    };
    masks?: Record<string, unknown>;
    debug?: boolean;
  }

  class Card {
    constructor(options: CardJsOptions);
    destroy?(): void;
  }

  export = Card;
}
