# iOS 26 Guide

# Best Practices
Great iPhone experiences integrate the platform and device capabilities that people value most. To help your design feel at home in iOS, prioritize the following ways to incorporate these features and capabilities.

Help people concentrate on primary tasks and content by limiting the number of onscreen controls while making secondary details and actions discoverable with minimal interaction.

Adapt seamlessly to appearance changes — like device orientation, Dark Mode, and Dynamic Type — letting people choose the configurations that work best for them.

Support interactions that accommodate the way people usually hold their device. For example, it tends to be easier and more comfortable for people to reach a control when it’s located in the middle or bottom area of the display, so it’s especially important let people swipe to navigate back or initiate actions in a list row.

With people’s permission, integrate information available through platform capabilities in ways that enhance the experience without asking people to enter data. For example, you might accept payments, provide security through biometric authentication, or offer features that use the device’s location.

# Materials
A material is a visual effect that creates a sense of depth, layering, and hierarchy between foreground and background elements.
A sketch of overlapping squares, suggesting the use of transparency to hint at background content. The image is overlaid with rectangular and circular grid lines and is tinted yellow to subtly reflect the yellow in the original six-color Apple logo.

Materials help visually separate foreground elements, such as text and controls, from background elements, such as content and solid colors. By allowing color to pass through from background to foreground, a material establishes visual hierarchy to help people more easily retain a sense of place.

Apple platforms feature two types of materials: Liquid Glass, and standard materials. Liquid Glass is a dynamic material that unifies the design language across Apple platforms, allowing you to present controls and navigation without obscuring underlying content. In contrast to Liquid Glass, the standard materials help with visual differentiation within the content layer.

Liquid Glass
Liquid Glass forms a distinct functional layer for controls and navigation elements — like tab bars and sidebars — that floats above the content layer, establishing a clear visual hierarchy between functional elements and content. Liquid Glass allows content to scroll and peek through from beneath these elements to give the interface a sense of dynamism and depth, all while maintaining legibility for controls and navigation.

An image of four intersecting shapes of Liquid Glass material, floating above a neutral background. The shapes act as lenses in the areas where they overlap, bending and shading the surfaces beneath them. They cast shadows on the background layer that show through the material and cause it to subtly darken in patterns matching the shapes above.

Don’t use Liquid Glass in the content layer. Liquid Glass works best when it provides a clear distinction between interactive elements and content, and including it in the content layer can result in unnecessary complexity and a confusing visual hierarchy. Instead, use standard materials for elements in the content layer, such as app backgrounds. An exception to this is for controls in the content layer with a transient interactive element like sliders and toggles; in these cases, the element takes on a Liquid Glass appearance to emphasize its interactivity when a person activates it.

Use Liquid Glass effects sparingly. Standard components from system frameworks pick up the appearance and behavior of this material automatically. If you apply Liquid Glass effects to a custom control, do so sparingly. Liquid Glass seeks to bring attention to the underlying content, and overusing this material in multiple custom controls can provide a subpar user experience by distracting from that content. Limit these effects to the most important functional elements in your app. For developer guidance, see Applying Liquid Glass to custom views.

Only use clear Liquid Glass for components that appear over visually rich backgrounds. Liquid Glass provides two variants — regular and clear — that you can choose when building custom components or styling some system components.

The regular variant blurs and adjusts the luminosity of background content to maintain legibility of text and other foreground elements. Scroll edge effects further enhance legibility by blurring and reducing the opacity of background content. Most system components use this variant. Use the regular variant when background content might create legibility issues, or when components have a significant amount of text, such as alerts, sidebars, or popovers.

A visual example of the regular variant of Liquid Glass, which appears darker when there is a dark background beneath it.
On dark background

A visual example of the regular variant of Liquid Glass, which appears lighter when there is a light background beneath it.
On light background

The clear variant is highly translucent, which is ideal for prioritizing the visibility of the underlying content and ensuring visually rich background elements remain prominent. Use this variant for components that float above media backgrounds — such as photos and videos — to create a more immersive content experience.

A visual example of the clear variant of Liquid Glass, which allows the visual detail of the background beneath it to show through.

For optimal contrast and legibility, determine whether to add a dimming layer behind components with clear Liquid Glass:

If the underlying content is bright, consider adding a dark dimming layer of 35% opacity. For developer guidance, see clear.

If the underlying content is sufficiently dark, or if you use standard media playback controls from AVKit that provide their own dimming layer, you don’t need to apply a dimming layer.

For guidance about the use of color, see Liquid Glass color.

Standard materials
Use standard materials and effects — such as blur, vibrancy, and blending modes — to convey a sense of structure in the content beneath Liquid Glass.

Choose materials and effects based on semantic meaning and recommended usage. Avoid selecting a material or effect based on the apparent color it imparts to your interface, because system settings can change its appearance and behavior. Instead, match the material or vibrancy style to your specific use case.

Help ensure legibility by using vibrant colors on top of materials. When you use system-defined vibrant colors, you don’t need to worry about colors seeming too dark, bright, saturated, or low contrast in different contexts. Regardless of the material you choose, use vibrant colors on top of it. For guidance, see System colors.

An illustration of a Share button with a translucent background material and a symbol. The symbol uses the systemGray3 color and is difficult to see against the background material.
Poor contrast between the material and systemGray3 label

An X in a circle to indicate incorrect usage

An illustration of a Share button with a translucent background material and a symbol. The symbol uses vibrant color and is clearly visible against the background material.
Good contrast between the material and vibrant color label

A checkmark in a circle to indicate correct usage

Consider contrast and visual separation when choosing a material to combine with blur and vibrancy effects. For example, consider that:

Thicker materials, which are more opaque, can provide better contrast for text and other elements with fine features.

Thinner materials, which are more translucent, can help people retain their context by providing a visible reminder of the content that’s in the background.

For developer guidance, see Material.

Platform considerations
iOS, iPadOS
In addition to Liquid Glass, iOS and iPadOS continue to provide four standard materials — ultra-thin, thin, regular (default), and thick — which you can use in the content layer to help create visual distinction.

An illustration of the iOS and iPadOS ultraThin material above a colorful background. Where the material overlaps the background, it provides a diffuse gradient of the background colors.
ultraThin

An illustration of the iOS and iPadOS thin material above a colorful background. Where the material overlaps the background, it provides a diffuse and slightly darkened gradient of the background colors.
thin

An illustration of the iOS and iPadOS regular material above a colorful background. Where the material overlaps the background, it provides a diffuse and darkened gradient of the background colors.
regular

An illustration of the iOS and iPadOS thick material above a colorful background. Where the material overlaps the background, it provides a dark, muted gradient of the background colors.
thick

iOS and iPadOS also define vibrant colors for labels, fills, and separators that are specifically designed to work with each material. Labels and fills both have several levels of vibrancy; separators have one level. The name of a level indicates the relative amount of contrast between an element and the background: The default level has the highest contrast, whereas quaternary (when it exists) has the lowest contrast.

Except for quaternary, you can use the following vibrancy values for labels on any material. In general, avoid using quaternary on top of the thin and ultraThin materials, because the contrast is too low.

UIVibrancyEffectStyle.label (default)

UIVibrancyEffectStyle.secondaryLabel

UIVibrancyEffectStyle.tertiaryLabel

UIVibrancyEffectStyle.quaternaryLabel

You can use the following vibrancy values for fills on all materials.

UIVibrancyEffectStyle.fill (default)

UIVibrancyEffectStyle.secondaryFill

UIVibrancyEffectStyle.tertiaryFill

The system provides a single, default vibrancy value for a separator, which works well on all materials.
