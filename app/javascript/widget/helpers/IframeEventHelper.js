export const loadedEventConfig = () => {
  return {
    event: 'loaded',
    config: {
      authToken: window.authToken,
      channelConfig: window.kirvanoWebChannel,
    },
  };
};

export const getExtraSpaceToScroll = () => {
  // This function calculates the extra space needed for the view to
  // accommodate the height of close button + height of
  // read messages button. So that scrollbar won't appear
  const unreadMessageWrap = document.querySelector('.unread-messages');
  const unreadCloseWrap = document.querySelector('.close-unread-wrap');
  const readViewWrap = document.querySelector('.open-read-view-wrap');

  if (!unreadMessageWrap) return 0;

  // 24px to compensate the paddings
  let extraHeight = 48 + unreadMessageWrap.scrollHeight;
  if (unreadCloseWrap) extraHeight += unreadCloseWrap.scrollHeight;
  if (readViewWrap) extraHeight += readViewWrap.scrollHeight;

  return extraHeight;
};

export const shouldTriggerMessageUpdateEvent = message => {
  const { previous_changes: previousChanges } = message;

  if (!previousChanges) {
    return false;
  }
  const hasNotifiableAttributeChanges =
    Object.keys(previousChanges).includes('content_attributes');
  if (!hasNotifiableAttributeChanges) {
    return false;
  }

  const hasSubmittedValueChanges = Object.keys(
    previousChanges.content_attributes[1] || {}
  ).includes('submitted_values');

  return hasSubmittedValueChanges;
};
