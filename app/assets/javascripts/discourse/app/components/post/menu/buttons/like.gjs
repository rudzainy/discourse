import Component from "@glimmer/component";
import { tracked } from "@glimmer/tracking";
import { action } from "@ember/object";
import { inject as service } from "@ember/service";
import DButton from "discourse/components/d-button";
import concatClass from "discourse/helpers/concat-class";
import icon from "discourse-common/helpers/d-icon";
import i18n from "discourse-common/helpers/i18n";
import discourseLater from "discourse-common/lib/later";

export default class PostMenuLikeButton extends Component {
  static shouldRender(args) {
    return args.post.showLike;
  }

  @service currentUser;

  @tracked isAnimated = false;

  get disabled() {
    return this.currentUser && !this.args.post.canToggleLike;
  }

  get title() {
    // If the user has already liked the post and doesn't have permission
    // to undo that operation, then indicate via the title that they've liked it
    // and disable the button. Otherwise, set the title even if the user
    // is anonymous (meaning they don't currently have permission to like);
    // this is important for accessibility.

    if (this.args.post.liked && !this.args.post.canToggleLike) {
      return "post.controls.has_liked";
    }

    return this.args.post.liked
      ? "post.controls.undo_like"
      : "post.controls.like";
  }

  @action
  async toggleLike() {
    this.isAnimated = true;

    return new Promise((resolve) => {
      discourseLater(async () => {
        this.isAnimated = false;
        await this.args.buttonActions.toggleLike();
        resolve();
      }, 400);
    });
  }

  <template>
    {{#if @shouldRender}}
      <div class="double-button">
        <LikeCount
          ...attributes
          @action={{@buttonActions.toggleWhoLiked}}
          @context={{@context}}
          @post={{@post}}
        />
        <DButton
          class={{concatClass
            "btn-icon"
            "toggle-like"
            (if this.isAnimated "heart-animation")
            (if @post.liked "has-like fade-out" "like")
          }}
          ...attributes
          data-post-id={{@post.id}}
          disabled={{this.disabled}}
          @action={{this.toggleLike}}
          @icon={{if @post.liked "d-liked" "d-unliked"}}
          @label={{if @showLabel "post.controls.like_action"}}
          @title={{this.title}}
        />
      </div>
    {{else if @post.likeCount}}
      <div class="double-button">
        <LikeCount
          ...attributes
          @action={{@buttonActions.toggleWhoLiked}}
          @context={{@context}}
          @post={{@post}}
        />
      </div>
    {{/if}}
  </template>
}

class LikeCount extends Component {
  get icon() {
    if (!this.args.post.showLike) {
      return this.args.post.yours ? "d-liked" : "d-unliked";
    }

    if (this.args.post.yours) {
      return "d-liked";
    }
  }

  get translatedTitle() {
    let title;

    if (this.args.post.liked) {
      title =
        this.args.post.likeCount === 1
          ? "post.has_likes_title_only_you"
          : "post.has_likes_title_you";
    } else {
      title = "post.has_likes_title";
    }

    return i18n(title, {
      count: this.args.post.liked
        ? this.args.post.likeCount - 1
        : this.args.post.likeCount,
    });
  }

  <template>
    {{#if @post.likeCount}}
      <DButton
        class={{concatClass
          "button-count"
          "like-count"
          "highlight-action"
          (if @post.yours "my-likes" "regular-likes")
        }}
        ...attributes
        @ariaPressed={{@context.isWhoReadVisible}}
        @translatedAriaLabel={{i18n
          "post.sr_post_like_count_button"
          count=@post.likeCount
        }}
        @translatedTitle={{this.translatedTitle}}
        @action={{@action}}
      >
        {{@post.likeCount}}
        {{!--
           When displayed, the icon on the Like Count button is aligned to the right
           To get the desired effect will use the {{yield}} in the DButton component to our advantage
           introducing manually the icon after the label
          --}}
        {{#if this.icon}}
          {{~icon this.icon~}}
        {{/if}}
      </DButton>
    {{/if}}
  </template>
}
