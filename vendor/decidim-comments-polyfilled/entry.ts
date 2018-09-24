/**
 * Polyfilled entry point for comments
 */

// Add polyfills to fix IE11 issues
// Currently using core-js v2
// When upgrading to v3, replace "fn" with "features".
import "core-js/fn/object/assign";
import "core-js/fn/promise";

// Import the comments app
import "../decidim-comments/app/frontend/entry";
